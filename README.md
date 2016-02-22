A quick example of how to generate configs for scaling docker containers by using the api for service discovery

	docker-compose up -d

	docker-compose scale app=3

	bundle exec ruby ha-proxy-config-generator.rb > haproxy.cfg

	docker run -d -p 80:80 --net yggdrasil --name haproxy -v ${PWD}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy

if you have hello_world.dev and nginx.dev pointed to your docker host in /etc/hosts, you'll see the tutum hello world round-robin between 3 hostnames
