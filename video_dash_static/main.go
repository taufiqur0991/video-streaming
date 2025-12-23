package main

import (
	"log"
	"net/http"
)

func main() {
	// Folder "content" untuk file DASH, sisanya untuk index.html
	fs := http.FileServer(http.Dir("./"))

	// Middleware sederhana untuk CORS (penting untuk streaming)
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		fs.ServeHTTP(w, r)
	})

	log.Println("Server jalan di http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}
