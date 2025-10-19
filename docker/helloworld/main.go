package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// counts root endpoint hits
	requestsTotal = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "helloworld_requests_total",
			Help: "Total number of requests to the root endpoint",
		},
	)
)

func main() {
	prometheus.MustRegister(requestsTotal)

	mux := setupRoutes()
	server := newServer(mux)

	log.Printf("Starting HelloWorld on %s", server.Addr)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// setupRoutes creates and returns the mux with all endpoints registered.
func setupRoutes() *http.ServeMux {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		requestsTotal.Inc()
		fmt.Fprintf(w, "Hello, World!\n")
	})

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	mux.Handle("/metrics", promhttp.Handler())

	return mux
}

func newServer(handler http.Handler) *http.Server {
	port := getEnv("PORT", "8080")
	return &http.Server{
		Addr:         ":" + port,
		Handler:      logRequest(handler),
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
}

func getEnv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

// logRequest is a middleware that logs each HTTP request.
func logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
	})
}
