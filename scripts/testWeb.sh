#!/bin/bash

source scripts/multiArchMatrix.sh
source scripts/logger.sh


function cleanup () {
	logSubTitle "Stopping test container"
	docker stop nginx-php-fpm-test
	logSubTitle "Removing test container"
	docker rm nginx-php-fpm-test
}

echo ""
logTitle "Testing image: edofede/nginx-php-fpm:$1"

logSubTitle "Creating test container"
docker create --name nginx-php-fpm-test --publish-all edofede/nginx-php-fpm:$1


logSubTitle "Starting test container"
docker start nginx-php-fpm-test
sleep 2


logSubTitle "Checking syslog-ng startup"
log=$(docker logs --tail 1 nginx-php-fpm-test |sed 's/.*\(syslog-ng starting up\).*/\1/')
if [[ "$log" != "syslog-ng starting up" ]]; then
	logError "Error: syslog-ng not started"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Test passed"


logSubTitle "Getting published TCP port on host"
webPort=$(docker port nginx-php-fpm-test 80/tcp |cut -d ':' -f2)
if [[ -z $webPort ]]; then
	logError "Error: unable to find published port"
	logDetail "Docker port output: $(docker port nginx-php-fpm-test)"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Port 80 mapped to: $webPort"


# Skip HTTP test for emulated architectures
archUnderTest=$(echo $1 |cut -d '-' -f2)
for i in ${!ARCHS[@]}; do
	if [[ "${ARCHS[i]}" == "$archUnderTest" ]]; then
		if [[ "${TEST_ENABLED[i]}" == "0" ]]; then
			logNormal "Skipping HTTP tests for this architecture"
			cleanup
			exit 0;
		fi
	fi
done


logSubTitle "Checking response from web server (HTML Static content)"
testPageResult=$(curl -sS http://localhost:$webPort/testPage.html)
expectedResult="<html><head><title>nginx-php-fpm test page</title></head></html>"
if [[ -z $testPageResult ]]; then
	logError "Error: no output from the webserver"
	logError "Aborting..."
	cleanup
	exit 1;
fi
if [[ "$testPageResult" != "$expectedResult" ]]; then
	logError "Error: http result mismatch from expected"
	logDetail "Expected: $expectedResult"
	logDetail "Received: $testPageResult"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Test passed"


logSubTitle "Checking response from web server (PHP Dynamic content)"
testPageResult=$(curl -sS http://localhost:$webPort/testPage.php)
expectedResult="<html><head><title>nginx-php-fpm PHP test page</title></head></html>"
if [[ -z $testPageResult ]]; then
	logError "Error: no output from the webserver"
	logError "Aborting..."
	cleanup
	exit 1;
fi
if [[ "$testPageResult" != "$expectedResult" ]]; then
	logError "Error: http result mismatch from expected"
	logDetail "Expected: $expectedResult"
	logDetail "Received: $testPageResult"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Test passed"

cleanup
