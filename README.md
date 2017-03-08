# HTTP log monitoring console program

## Requirements

You only need Ruby to run this program. It has been developed to avoid any dependencies.

Follow the instructions on the above link for installing Ruby:
 [https://www.ruby-lang.org/en/documentation/installation/](https://www.ruby-lang.org/en/documentation/installation/)

## Getting Started

Once Ruby is installed, simply run the `./terminalog` program. You can find the following help running `./terminalog -h`

```ruby
Usages: ./terminalog ACCESS_LOG_FILENAME [options]
	tail -f ACCESS_LOG_FILENAME | ./terminalog [options]

    -h, --help                       Prints this help
    -i, --hits NUMBER                Hits alert threshold (default: 10000)
    -t, --threshold SECONDS          Access log retention threshold (default: 120s)
    -s, --screen SECONDS             Maximum screen refresh (default: 1s)
```

## Further Explanations

**Overview**

The program takes a stream in and parse it. Valid logs are put into an internal queue/pipeline. Stats are computed on the fly for each new event. Every n seconds (defined by the user), the pipeline is flushed from old events which date is greater than the set threshold retention. We also check if alerts thresholds are crossed and emit an alert if that's the case. The console UI is refreshed.

**Consume an actively written-to w3c-formatted HTTP access log**

The program can ingest HTTP access log by specifying the filename in arguments or by piping the content directly.   
It parses and accepts the regular and combined Common Log format.

**Every 10s, display in the console the sections of the web site with the most hits, as well as interesting summary statistics on the traffic as a whole.**

By default, screen refresh is set to 1s, but you can run it like this: `./terminalog -s 10`

You can find on the dashboard the required informations, but also some extras like the Top 3 HTTP status / IPs, the last ingested logs, the total number of alerts etc.

**Make sure a user can keep the console app running and monitor traffic on their machine**

This program respects UNIX/POSIX principles. So you can simply put the program in background when you feel like it and put it back in foreground. It will still ingest data and compute it.

Example:

`tail -f apache.log | ./terminalog > daemon.log 2>&1 &`

**Whenever total traffic for the past 2 minutes exceeds a certain number on average, add a message saying that “High traffic generated an alert - hits = {value}, triggered at {time}”**

**Whenever the total traffic drops again below that value on average for the past 2 minutes, add another message detailing when the alert recovered**

**Make sure all messages showing when alerting thresholds are crossed remain visible on the page for historical reasons**

The alert will be displayed on top of the dashboard to avoid unnecessary scrolling when there is too many alerts.

**Write a test for the alerting logic**

In order to run the test successfully, you need to install the `rspec` gem:

`$ gem install rspec`

Then, you can run the test suits by invoking `rspec` in the program directory.

**Explain how you’d improve on this application design**

The program has been designed in such a way that the UI and and the computing part are separated. But one could go further and completely decoupled these two. The computing part could write its current status to a file and whatever UI could ingest that and display the informations.

Following on that, the current design of the dashboard printed to the console isn't great. This is clearly not my strength...

The current pipeline statistics are discarded upon flush because there was no requirement to keep it. In production, we would certainly keep these stats, probably by creating buckets of stats for some given interval.

In production, the program should run as a daemon in order to start/stop/autorestart it automatically in case of crash, reboot of the server, etc.

It would also need to communicate the generated stats to a remote server via TCP which would collect and store the data on its end.

The program currently can ingest >10k events per second but in production, it would need to ingest more and in a more robust manner without blocking. It could do this by using more threads for example.

Statistics and alerts are currently hardcoded. A better production ready design would allow to dynamically add different types of stats and alerts thresholds.

## Contact

Please let me know if you run into any trouble to run this program or if you have any question about it.

Thank you
