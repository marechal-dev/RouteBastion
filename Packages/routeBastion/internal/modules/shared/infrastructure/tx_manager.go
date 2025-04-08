package infrastructure

import (
	"context"

	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database"
	"github.com/marechal-dev/RouteBastion/Packages/routeBastion/internal/database/generated"
)

type TxManager interface {
	Do(ctx context.Context, fn func(q *generated.Queries) error) error
}

type TxManagerImpl struct {
	db *database.DatabaseServiceImpl
}

func (tm *TxManagerImpl) Do(ctx context.Context, fn func(q *generated.Queries) error) error {
	tx, err := tm.db.GetConn().Begin(ctx)
	if err != nil {
		return err
	}
	qtx := tm.db.GetQueriesWithTx(tx)
	err = fn(qtx)

	if err != nil {
		_ = tx.Rollback(ctx)
		return err
	}

	return tx.Commit(ctx)
}
