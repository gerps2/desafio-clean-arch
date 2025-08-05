package webserver

import (
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

type WebServer struct {
	Router        chi.Router
	Handlers      map[string]http.HandlerFunc
	WebServerPort string
}

func NewWebServer(serverPort string) *WebServer {
	return &WebServer{
		Router:        chi.NewRouter(),
		Handlers:      make(map[string]http.HandlerFunc),
		WebServerPort: serverPort,
	}
}

func (s *WebServer) AddHandler(path string, handler http.HandlerFunc) {
	s.Handlers[path] = handler
}

func (s *WebServer) AddHandlerWithMethod(method, path string, handler http.HandlerFunc) {
	key := method + ":" + path
	s.Handlers[key] = handler
}

// loop through the handlers and add them to the router
// register middeleware logger
// start the server
func (s *WebServer) Start() {
	s.Router.Use(middleware.Logger)
	for key, handler := range s.Handlers {
		if len(key) > 0 && key[0] != '/' {
			// Handle method:path format
			parts := strings.SplitN(key, ":", 2)
			if len(parts) == 2 {
				method, path := parts[0], parts[1]
				s.Router.Method(method, path, handler)
			}
		} else {
			// Handle legacy path-only format
			s.Router.Handle(key, handler)
		}
	}
	http.ListenAndServe(s.WebServerPort, s.Router)
}
