package sharedInfrastucture

import (
	"errors"
	"time"

	"github.com/jackc/pgx/v5/pgtype"
)

func ConvertPgtypeTimestampToTime(ts pgtype.Timestamp) (time.Time, error) {
	if !ts.Valid {
		return time.Time{}, errors.New("timestamp is not valid")
	}
	return ts.Time, nil
}

func ConvertTimeToPgtypeTimestamp(t time.Time) pgtype.Timestamp {
	return pgtype.Timestamp{
		Time:  t,
		Valid: true,
	}
}
