package main

import (
	"io"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	router.LoadHTMLFiles("templates/index.tmpl")
	version := os.Getenv("VERSION")
	client := http.Client{
		Timeout: 2 * time.Second,
	}

	router.GET("/", func(c *gin.Context) {
		c.Header("Cache-Control", "no-cache")
		resp, err := client.Get("http://169.254.169.254/latest/meta-data/instance-id")
		instance_id := "Unknown"
		if err == nil {
			body, err := io.ReadAll(resp.Body)
			if err == nil {
				instance_id = string(body)
			}
		}

		c.HTML(http.StatusOK, "index.tmpl", gin.H{
			"app_version": version,
			"instance_id": instance_id,
		})
	})
	router.Run(":8080")
}
