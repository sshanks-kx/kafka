//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//                    File Decription                    //
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//

/
* @file test_stage2.q
* @fileoverview
* Conduct tests from the stage where subscription is completed.
\

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//                          Tests                        //
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//

// Get current number of rows.
current_offset_1:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]
current_offset_2:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic2; enlist 1i]

// Publish message
.kafka.publish[topic1; 1i; "Hello"; "greeting1"];
.kafka.publish[topic2; 1i; "Hello"; "greeting2"];
.kafka.publish[topic1; 1i; "Hello2"; "greeting1"];

// Flush the handle
.kafka.flushProducerHandle[producer; 1000];

// Ensure time elapses for 60 seconds.
.test.ASSERT_EQ[last exec offset from .kafka.getEarliestOffsetsForTimes[consumer; `topic1; enlist[1i]!enlist .z.p-0D00:01:00.000000000; 1000]; current_offset_1];
.test.ASSERT_EQ[last exec offset from .kafka.getEarliestOffsetsForTimes[consumer; `topic2; enlist[1i]!enlist .z.p-0D00:01:00.000000000; 1000]; current_offset_2];

.test.ASSERT_EQ[(last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]) - current_offset_1; 2]
.test.ASSERT_EQ[(last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic2; enlist 1i]) - current_offset_2; 1]

// Get current number of rows.
current_offset_1:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]
current_offset_2:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic2; enlist 1i]

// Get current table sizes.
current_num_rows_1: count consumer_table1;
current_num_rows_1: count consumer_table2;

// Assign new offset
.kafka.assignNewOffsetsToTopicPartition[consumer; `topic1; enlist[1i]!enlist 1];
.kafka.assignNewOffsetsToTopicPartition[consumer; `topic2; enlist[1i]!enlist 1];

// Ensure consumer received everything
while[not 0 = .kafka.getOutQueueLength consumer; .kafka.manualPoll[consumer; 1000; 100]];

// Read 
.test.ASSERT_EQ[count[consumer_table1]-current_num_rows_1; current_offset_1]
.test.ASSERT_EQ[count[consumer_table2]-current_num_rows_2; current_offset_2]

// Get current number of rows.
current_offset_1:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]
current_offset_2:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic2; enlist 1i]

// Publish messages
.kafka.publishBatch[topic1; 1i; ("batch hello"; "batch hello2"); ""];

// Flush the handle
.kafka.flushProducerHandle[producer; 1000];

.test.ASSERT_EQ[(last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]) - current_offset_1; 2]

// Publish messages
.kafka.publishBatch[topic2; 1 1i; ("batch hello"; "batch hello2"); ""];

// Flush the handle
.kafka.flushProducerHandle[producer; 1000];

.test.ASSERT_EQ[(last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic2; enlist 1i]) - current_offset_2; 2]

current_offset_1:last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]

// Publish with headers.
.kafka.publishWithHeaders[producer; topic1; 1i; "locusts"; ""; `header1`header2!("firmament"; "divided")];

// Flush the handle
.kafka.flushProducerHandle[producer; 1000];

.test.ASSERT_EQ[(last exec offset from .kafka.getCommittedOffsetsForTopicPartition[consumer; `topic1; enlist 1i]) - current_offset_1; 1]

.test.DISPLAY_RESULT[];