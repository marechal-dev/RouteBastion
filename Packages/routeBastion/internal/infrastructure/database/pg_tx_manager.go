package database

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// txKey is an unexported type for storing the transaction in the context.
type txKey struct{}

type PgTxManager struct {
	db *pgxpool.Pool
}

func NewPgTxManager(db *pgxpool.Pool) *PgTxManager {
	return &PgTxManager{db: db}
}

// WithinTransaction starts a transaction, executes the provided function,
// and then commits or rolls back as needed.
func (tm *PgTxManager) WithinTransaction(
	ctx context.Context,
	fn func(ctx context.Context) error,
) error {
	tx, err := tm.db.Begin(ctx)
	if err != nil {
		return err
	}

	// Recover from panics to ensure the transaction is properly rolled back.
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback(ctx)
			panic(p)
		}
	}()

	txCtx := context.WithValue(ctx, txKey{}, tx)

	if err := fn(txCtx); err != nil {
		_ = tx.Rollback(ctx)
		return err
	}

	return tx.Commit(ctx)
}

// ExtractTx is a helper to retrieve the pgx.Tx from the context.
func ExtractTx(ctx context.Context) (pgx.Tx, error) {
	tx, ok := ctx.Value(txKey{}).(pgx.Tx)

	if !ok {
		return nil, errors.New("transaction not found in context")
	}

	return tx, nil
}
