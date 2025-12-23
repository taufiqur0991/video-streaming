package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func main() {
	// 1. Route untuk Index Player
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "index.html")
	})

	// 2. Sajikan file video (m3u8 & ts)
	fs := http.FileServer(http.Dir("./encrypted_video"))
	http.Handle("/stream/", http.StripPrefix("/stream/", fs))

	// 3. Websocket Endpoint untuk Kirim Key
	http.HandleFunc("/ws-key", func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			return
		}
		defer conn.Close()

		for {
			_, p, err := conn.ReadMessage()
			if err != nil {
				return
			}

			// Jika client minta "get-key"
			if string(p) == "get-key" {
				keyData, _ := os.ReadFile("./keys/video.key")
				// Kirim key dalam bentuk Binary via Websocket
				conn.WriteMessage(websocket.BinaryMessage, keyData)
				fmt.Println("Key dikirim via Websocket!")
			}
		}
	})

	fmt.Println("Server running at http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
