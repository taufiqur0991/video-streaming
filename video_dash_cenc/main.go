package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func main() {
	// Sajikan file statis
	http.Handle("/", http.FileServer(http.Dir(".")))

	http.HandleFunc("/ws-get-cenc", func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			fmt.Println("Gagal upgrade ke WebSocket:", err)
			return
		}
		// Pastikan koneksi ditutup saat fungsi selesai
		defer conn.Close()

		fmt.Println("Client terhubung ke WebSocket")

		for {
			// Membaca pesan dari client
			_, msg, err := conn.ReadMessage()
			if err != nil {
				// ERROR HANDLING: Keluar dari loop jika koneksi bermasalah
				fmt.Println("Koneksi WebSocket putus atau error:", err)
				break
			}

			if string(msg) == "get-cenc-keys" {
				fmt.Println("Mengirim kunci CENC...")
				keys := map[string]string{
					"kid": "63326164363533353332333433303339",
					"key": "31323334353637383930313233343536",
				}

				err := conn.WriteJSON(keys)
				if err != nil {
					fmt.Println("Gagal mengirim JSON:", err)
					break
				}
			}
		}
	})

	fmt.Println("Server DASH CENC jalan di http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
