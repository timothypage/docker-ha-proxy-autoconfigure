add the following to your /etc/hosts

    192.168.99.100 green-app.sxglocal.com
    192.168.99.100 blue-app.sxglocal.com
    192.168.99.100 yellow-app.sxglocal.com
    192.168.99.100 basic-app.sxglocal.com

A quick example of how to generate configs for scaling docker containers by using the api for service discovery

	  docker-compose up -d && bundle exec ruby config-generator.rb

  	docker-compose scale green_app=3 && bundle exec ruby config-generator.rb


visit green-app.sxglocal.com to see nginx round-robin between 3 containers
