#!/bin/bash

# Change to the directory with our code that we plan to work from
cd "$GOPATH/src/galleries.com"

echo "==== Releasing galleries.com ===="
echo "  Deleting the local binary if it exists (so it isn't uploaded)..."
rm galleries.com
echo "  Done!"

echo "  Deleting existing code..."
ssh root@screencast.galleries.com "rm -rf /root/go/src/galleries.com"
echo "  Code deleted successfully!"

echo "  Uploading code..."
rsync -avr --exclude '.git/*' --exclude 'tmp/*' --exclude 'images/*' ./ root@screencast.galleries.com:/root/go/src/galleries.com/
echo "  Code uploaded successfully!"

echo "  Go getting deps..."
ssh root@screencast.galleries.com "export GOPATH=/root/go; /usr/local/go/bin/go get golang.org/x/crypto/bcrypt"
ssh root@screencast.galleries.com "export GOPATH=/root/go; /usr/local/go/bin/go get github.com/gorilla/mux"
ssh root@screencast.galleries.com "export GOPATH=/root/go; /usr/local/go/bin/go get github.com/gorilla/schema"
ssh root@screencast.galleries.com "export GOPATH=/root/go; /usr/local/go/bin/go get github.com/lib/pq"
ssh root@screencast.galleries.com "export GOPATH=/root/go; /usr/local/go/bin/go get github.com/jinzhu/gorm"
ssh root@screencast.galleries.com "export GOPATH=/root/go; /usr/local/go/bin/go get github.com/gorilla/csrf"

echo "  Building the code on remote server..."
ssh root@screencast.galleries.com 'export GOPATH=/root/go; cd /root/app; /usr/local/go/bin/go build -o ./server $GOPATH/src/galleries.com/*.go'
echo "  Code built successfully!"

echo "  Moving assets..."
ssh root@screencast.galleries.com "cd /root/app; cp -R /root/go/src/galleries.com/assets ."
echo "  Assets moved successfully!"

echo "  Moving views..."
ssh root@screencast.galleries.com "cd /root/app; cp -R /root/go/src/galleries.com/views ."
echo "  Views moved successfully!"

echo "  Moving Caddyfile..."
ssh root@screencast.galleries.com "cd /root/app; cp /root/go/src/galleries.com/Caddyfile ."
echo "  Views moved successfully!"

echo "  Restarting the server..."
ssh root@screencast.galleries.com "sudo service galleries.com restart"
echo "  Server restarted successfully!"

echo "  Restarting Caddy server..."
ssh root@screencast.galleries.com "sudo service caddy restart"
echo "  Caddy restarted successfully!"

echo "==== Done releasing galleries.com ===="
