# Build an image based on Python 3
FROM python:3.7

# Create the uwsgi group and add the user uwsgi from which commands will be run
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi

# Install Python 3 dependencies as python2 is pan breid
RUN pip3 install FLASK uwsgi requests redis

# Set the current working directory for the next command
WORKDIR /app

#Copy the conents of app into /app
COPY app /app

# Copy in the shell script
COPY cmd.sh /

# Expose the ports - which can be assigned to random ports
EXPOSE 9090 9191

#Set the user for the next command
USER uwsgi

# Note that this didn't work in exec form
# CMD ["uwsgi" , "--http", "0.0.0.0:9090","--wsgi-file", "./app/identidock.py","--callable", "app" "--stats", "0.0.0.0:9191"]

# This is shell form and did work
# CMD uwsgi --http 0.0.0.0:9090 --wsgi-file /app/identidock.py --callable app --stats 0.0.0.0:9191

# Now try running the script rather than above commands
CMD ["/cmd.sh"]
