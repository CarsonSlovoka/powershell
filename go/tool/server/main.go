package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
)

func initUrls(m *http.ServeMux) error {
	m.HandleFunc("/invokeRequest/", func(w http.ResponseWriter, r *http.Request) {
		maxAllowedSize := int64(1 << 20) // 1 MB 防止太大的檔案上傳
		r.Body = http.MaxBytesReader(w, r.Body, maxAllowedSize)

		log.Printf("%+v\n", r.Header)

		var inputStr string
		if r.Header.Get("Content-Type") == "application/json;charset=utf-8" {
			var input map[string]any
			if err := json.NewDecoder(r.Body).Decode(&input); err != nil && err != io.EOF {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			if input != nil {
				log.Printf("application/json: %+v\n", input)
				inputStr = fmt.Sprintf("%+v", input)
			}
		} else {
			inputBody, err := io.ReadAll(r.Body)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			log.Printf("body: %s\n", string(inputBody))
			inputStr = string(inputBody)
		}

		jsonData := struct {
			Input  string `json:"input,omitempty"`
			Output string
			Id     int
		}{
			inputStr,
			"Hello World",
			123,
		}
		enc := json.NewEncoder(w)
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		if err := enc.Encode(jsonData); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
		}
	})

	m.HandleFunc("/upload/", upload)

	return nil
}

func upload(w http.ResponseWriter, r *http.Request) {
	contentType := r.Header.Get("Content-Type")
	if strings.Split(contentType, ";")[0] != "multipart/form-data" {
		http.Error(w, "Content-Typer error", http.StatusForbidden)
		return
	}

	maxMBSize := 1
	maxAllowedSize := int64(maxMBSize << 20)
	r.Body = http.MaxBytesReader(w, r.Body, maxAllowedSize)
	if err := r.ParseMultipartForm(maxAllowedSize); err != nil {
		http.Error(w, fmt.Sprintf("檔案大小只能%dMB . %s", maxMBSize, err.Error()), http.StatusBadRequest)
		return
	}

	countOK := 0
	countErr := 0
	uploadDir := "./upload"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		log.Println(err)
		return
	}

	for name, values := range r.MultipartForm.Value {
		for i, val := range values {
			v, err := url.QueryUnescape(val)
			if err != nil {
				log.Println(err)
			}
			log.Println(name, i, v)
		}
	}

	// File
	for name, files := range r.MultipartForm.File { // 同一個name，可以允許有很多筆資料
		for idx, file := range files {
			f, _ := file.Open()
			bs, _ := io.ReadAll(f)
			if err := os.WriteFile(filepath.Join(uploadDir, file.Filename), bs, os.ModePerm); err != nil {
				log.Println(err)
				countErr++
			} else {
				log.Printf("name=%q; idx=%d, filename=%q upload success!\n", name, idx, file.Filename)
				countOK++
			}
			_ = f.Close()
		}
	}
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	_, _ = fmt.Fprintf(w, fmt.Sprintf("上傳完成.\n成功上傳檔案數量:%d\n上傳失敗的檔案數量%d", countOK, countErr))
}

func main() {
	mux := http.NewServeMux()
	if err := initUrls(mux); err != nil {
		log.Fatal(err)
	}
	server := &http.Server{Addr: "127.0.0.1:12345", Handler: mux}
	ln, err := net.Listen("tcp", server.Addr)
	if err != nil {
		log.Fatal(err)
	}
	log.Println(ln.Addr().String())
	if err := server.Serve(ln); err != nil {
		log.Fatal(err)
	}
}
