package health

import (
	"encoding/json"
	"net/http"
)

type Readiness struct {
	Status string
}

type Liveness struct {
	Status string
}

func ReadinessHandler(w http.ResponseWriter, r *http.Request) {
	status := Readiness{Status: "readiness ok"}

	obj, err := json.Marshal(status)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(obj)
}

func LivenessHandler(w http.ResponseWriter, r *http.Request) {
	status := Readiness{Status: "liveness ok"}

	obj, err := json.Marshal(status)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(obj)
}
