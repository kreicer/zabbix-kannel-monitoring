# Zabbix Kannel Template with Auto-discovery and support for multiple providers

## Main features

- Supports auto discovery of providers (SMSC)
- Easy configuration
- Low load on Zabbix server: most elements sending info by zabbix_sender
- Bash: no need to install Perl, PHP, Go or other languages. 

## Provided Items
We capture useful data from host and kannel status page:

- Kannel main statistic:

    - **Status** - the current status of Kannel
	- **Number of running smsboxes** - the number of running smsbox processes
	- **Number of running bearerboxes** - the number of running bearerbox processes
	- **SMS sent** - the number of sent SMS per minute
	- **SMS received** - the number of received SMS per minute
	- **DLR sent** - the number of sent delivery reports per minute
	- **DLR received** - the number of received delivery reports per minute
	- **Status page web check** - the answer code, load speed, response time and errors of Kannel status page

- For each SMSC provider:

    - **Uptime** - the uptime of current provider
    - **Status** - the status of current provider
	- **SMS sent** - the number of sent SMS per minute of current provider
	- **SMS received** - the number of received SMS per minute of current provider
	- **DLR sent** - the number of sent delivery reports per minute of current provider
	- **DLR received** - the number of received delivery reports per minute of current provider
	- **Failed** - the number of failed messages per minute of current provider
	- **Queued** - the number of queued messages per minute of current provider

History storage period is 7 days, trend storage period is 30 days.
Data is captured every minute.
These timings can be adjusted in template or per host if needed.

## Provided Triggers

- Bearerbox is not running
- SMSbox is not running
- Kannel is not running
- Bad response code for kannel status page
- Long response from kannel status page
- Kannel: {#SMSC} is not in online state (for each SMSC provider)

## Provided Graphs
#### Sent/Received SMS/DLR kannel (and for each provider)
![Zabbix Kannel Graph](https://github.com/kreicer/zabbix-kannel-monitoring/raw/master/img/graph1.png)

Displays the following data:

- SMS sent (overall or for provider) per minute
- SMS received (overall or for provider) per minute
- DLR sent (overall or for provider) per minute
- DLR received (overall or for provider) per minute
    
## Installation

### 1. On Target server
Perform the following operations on all servers with Zabbix Agent and Kannel from which you want to capture the data.

#### 1.1 Install required packages

```console
apt-get update
apt-get install libxml2-utils
```

#### 1.2 Download the latest version of the kannel monitoring, install files, restart zabbix-agent

```console
wget https://github.com/kreicer/zabbix-kannel-monitoring/archive/master.zip /tmp/zabbix-kannel-monitoring.zip
unzip /tmp/zabbix-kannel-monitoring.zip
cp /tmp/zabbix-kannel-monitoring/kannel-monitoring.conf /etc/zabbix/zabbix_agentd.conf/
cp /tmp/zabbix-kannel-monitoring/kannel-monitoring.sh /etc/zabbix/scripts/
chmod +x /etc/zabbix/scripts/kannel-monitoring.sh
systemctl restart zabbix-agent.service
```

If you using non-standart zabbix-agent.conf path change it in kannel-monitoring.sh

```console
zabbixconf="/etc/zabbix/zabbix_agentd.conf"
```

If you using password for status.xml change it in kannel-monitoring.sh

before
```console
curl "$xmlstatus" -o $xmlpath --silent
```

after
```console
curl "$xmlstatus?password=your_password_here" -o $xmlpath --silent
```

#### 1.3 Clean up
Delete temporary files:

```console
rm /tmp/zabbix-kannel-monitoring.zip
rm -r /tmp/zabbix-kannel-monitoring/
```

### 2. On Zabbix Server
#### 2.1 Import Zabbix kannel template
In Zabbix frontend go to `"Configuration"->"Templates"->"Import"`:

Upload file `/kannel_template.xml` from the [archive](https://github.com/kreicer/zabbix-kannel-monitoring/archive/master.zip).

#### 2.2 Add the template to your hosts
Add template "Kannel Template" to the hosts.

Add your status page (xml) address in the macros section of the host by adding value:

```
{$KANNEL_URL}=your status page address .xml
```

Setup is finished, just wait 15 minutes till Zabbix discovers your providers and captures the data (or use manual check).

# Compatibility
Tested with:
- Zabbix 4.2.5
- Kannel 1.4.5

Should work:
- Zabbix 4.x
- Zabbix 3.x
- Kannel 1.4.x

Not tested with:
- Kannel 1.3.x and earlier
- Zabbix 2.x

If it works, please let me know. 