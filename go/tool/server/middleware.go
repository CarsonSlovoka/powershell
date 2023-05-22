package main

import (
	"encoding/base64"
	"log"
	"net/http"
	"strings"
)

func Auth(handler func(w http.ResponseWriter, r *http.Request)) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			// 没有提供憑據，返回錯誤401
			w.Header().Set("WWW-Authenticate", `Basic realm="Restricted"`)
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		// 解析 Authorization 表頭的資料
		s := strings.SplitN(authHeader, " ", 2)
		if len(s) != 2 || s[0] != "Basic" { // 類似的內容 Basic A1E2BITz
			http.Error(w, "提供的憑據的格式不正確(表頭有誤)", http.StatusBadRequest)
			return
		}

		// 解碼憑據資料
		decoded, err := base64.StdEncoding.DecodeString(s[1])
		if err != nil {
			http.Error(w, "憑據解碼錯誤", http.StatusBadRequest)
			return
		}

		// 解析用户名和密码
		credentials := strings.SplitN(string(decoded), ":", 2) // user:psw
		username := credentials[0]
		password := credentials[1]

		log.Printf("\nUsername: %s\nPassword: %s\n", username, password)

		// 往下執行下一個Handler
		handler(w, r)
	}
}
