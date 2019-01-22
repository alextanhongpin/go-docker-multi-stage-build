package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	log.Println("Hello, go!")
	// Attempting to write to other directory other then the
	// allowed ones in the Dockerfile will result in the
	// following error:
	// 2019/01/22 07:51:37 open /hello.txt: permission denied
	f, err := os.Create("/tmp/hello.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	_, err = f.Write([]byte("hello world"))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("file written")
}
