module dlgo.time;

import std.datetime;

alias Time = DateTime;

// struct Time {
// }

// Time Date(Time self, year int, month Month, day, hour, min, sec, nsec int, loc *Location);
// Time Now(Time self, ) Time
// Tuple!(Time, error) Parse(Time self, layout, value string) 
// Tuple!(Time, error) ParseInLocation(Time self, layout, value string, loc *Location) 
// Time Unix(Time self, sec int64, nsec int64) 
// Time UnixMicro(Time self, usec int64) 
// Time UnixMilli(Time self, msec int64) 
// Time Add(Time self, d Duration) 
// Time AddDate(Time self, years int, months int, days int) 
// bool After(Time self, u Time) 
// ubyte[] AppendFormat(Time self, b []byte, layout string) 
// bool Before(Time self, u Time) 
// Tuple!(hour, min, int) Clock(Time self, )
// (Time self, year int, month Month, day int) Date() 
// int Day() 
// bool Equal(Time self, u Time) 
// string Format(Time self, layout string) 
// string GoString(Time self) 
// error GobDecode(Time *self, data []byte) 
// ([]byte, error) GobEncode(Time self) 
// int  Hour(Time self) 
// (year, week int)  ISOWeek(Time self) 
// bool In(Time self, loc *Location) 
// bool  (t Time) IsDST(Time self, ) 
// bool IsZero(Time self, ) 
// Time  Local(Time self, ) 
// *Location  Location(Time self, ) 
// ([]byte, error)  MarshalBinary(Time self, ) 
// ([]byte, error)  MarshalJSON(Time self, )
// ([]byte, error)  MarshalText(Time self, ) 
// int  Minute(Time self, ) 
// Month Month(Time self, ) 
// int Nanosecond(Time self, ) 
// Time Round(Time self, d Duration) 
// int Second(Time self, ) 
// string String(Time self, ) 
// Duration Sub(Time self, u Time) 
// Time Truncate(Time self, d Duration) 
// Time UTC(Time self, ) 
// int64 Unix(Time self, ) 
// int64 UnixMicro(Time self, ) 
// int64 UnixMilli(Time self, ) 
// int64 UnixNano(Time self, ) 
// error UnmarshalBinary(Time *self, data []byte) 
// error UnmarshalJSON(Time *self, data []byte) 
// error UnmarshalText(Time *self, data []byte) 
// Weekday Weekday(Time self) 
// int Year(Time self) 
// int YearDay(Time self) 
// (name string, offset int) Zone(Time self) 
// (start, end Time) ZoneBounds(Time self) 
