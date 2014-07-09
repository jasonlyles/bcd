web: bundle exec thin start -p $PORT

mailer: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work QUEUE=mailer
batchmailer: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work QUEUE=batchmailer