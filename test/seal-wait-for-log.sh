#!/bin/sh
# Seal fork-CI helper (Travis after_script). Travis archives job logs
# asynchronously, minutes behind the job; the harness harvests the log as soon
# as the build finishes, so without this wait it can read a log that stops
# before the QUnit results. Keep the job open until this job's own public log
# contains the runner's summary line. after_script cannot change the build
# result, so this never masks a failure.
url="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
pattern='^Tests: [0-9]+ passed, [0-9]+ failed'
i=0
while [ "$i" -lt 120 ]; do
	if curl -sfL "$url" | grep -Eq "$pattern"; then
		echo "seal-wait-for-log: test summary archived after $((i * 20))s"
		exit 0
	fi
	i=$((i + 1))
	sleep 20
done
echo "seal-wait-for-log: summary not archived after 40 min"
exit 0
