FROM d3fk/s3cmd
RUN apk update && apk --no-cache add openjdk8 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk add git maven
WORKDIR /usr/share/app-src
RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git ./
RUN  mvn package  -DskipTest
ADD .s3cfg /root/
RUN s3cmd --storage-class COLD put ./target/hello-1.0.war --storage-class COLD put s3://tf-bucket-yc/hello-1.0.war