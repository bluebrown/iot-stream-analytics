-- parse the raw data as json
CREATE STREAM MQTT_JSON (
  deviceId VARCHAR,
  parameterId VARCHAR,
  state VARCHAR,
  value VARCHAR,
  timestamp VARCHAR
) WITH (
  kafka_topic='mqtt-example',
  value_format='json',
  partitions=1,
  timestamp='timestamp',
  timestamp_format='yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''
);

-- rekey the stream by deviceId and parameterId
-- and register the schema in the schema registry
CREATE STREAM MQTT_REKEYED WITH (
  kafka_topic='device-parameter',
  key_format='protobuf',
  value_format='protobuf'
) AS SELECT
  deviceId,
  parameterId,
  state,
  CAST(value AS DOUBLE) AS value
FROM MQTT_JSON
PARTITION BY deviceId, parameterId
EMIT CHANGES;

-- perform some aggreation and store the result in a kafka topic
-- in this case window the data by 60 seconds and keep the data for 1 day
-- this allows to pivot the data on the time axis
CREATE TABLE WINDOWED_PARAMS WITH (
  kafka_topic='device-parameter-windowed',
  value_format='protobuf'
)
AS SELECT
  deviceId,
  parameterId,
  AS_VALUE(deviceId) did,
  AS_VALUE(parameterId) pid,
  MIN(value) AS min,
  MAX(value) AS max,
  AVG(value) AS avg,
  HISTOGRAM(state) AS hist,
  FROM_UNIXTIME(WINDOWSTART) as wstart,
  FROM_UNIXTIME(WINDOWEND) as wend,
  FROM_UNIXTIME(max(ROWTIME)) as wemit
FROM MQTT_REKEYED
WINDOW TUMBLING (SIZE 5 MINUTES, RETENTION 1 DAYS)
GROUP BY deviceId, parameterId
EMIT CHANGES;

