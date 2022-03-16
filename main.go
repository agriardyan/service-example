package main

import (
	"fmt"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/sirupsen/logrus"
)

func main() {
	opsProcessed := prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: "service_example",
			Name:      "http_requests_count",
			Help:      "Number of get requests.",
		},
		[]string{"path"},
	)

	prometheus.Register(opsProcessed)

	http.HandleFunc("/", func(rw http.ResponseWriter, r *http.Request) {
		opsProcessed.WithLabelValues("/").Inc()
		fmt.Fprint(rw, "Success!")
	})

	http.HandleFunc("/hello", func(rw http.ResponseWriter, r *http.Request) {
		opsProcessed.WithLabelValues("/hello").Inc()
		fmt.Fprint(rw, "Hello world!")
	})

	http.HandleFunc("/allo", func(rw http.ResponseWriter, r *http.Request) {
		opsProcessed.WithLabelValues("/allo").Inc()
		fmt.Fprint(rw, "Allo monde!")
	})

	http.Handle("/metrics", promhttp.Handler())

	fmt.Println("Server ready, listening at 8080")
	fmt.Println("Available endpoints are:")
	fmt.Println(`GET /`)
	fmt.Println(`GET /hello`)
	fmt.Println(`GET /allo`)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		logrus.Fatal(err)
	}
}
