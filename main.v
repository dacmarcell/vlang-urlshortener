module main

import xiusin.vredis
import veb
import time
import json

pub struct Context {
	veb.Context
}

pub struct App {
	pub:
		domain string
}

pub struct ShortenResponse {
	pub:
		shortened_url string
		error		  string
}

pub struct Url {
	pub:
		original_url  string
		shortened_url string
}

pub fn (app &App) shorten(mut ctx Context) veb.Result {
	original_url := ctx.query['url'] or {
		return ctx.json(ShortenResponse{
        	error: 'Invalid URL format'
    	})
	}

	short_id := time.now().unix().str()
	shortened_url := app.domain + short_id

	urls := json.encode(Url{
		shortened_url: shortened_url
		original_url: original_url
	})

	mut redis := vredis.new_client(host: '127.0.0.1', port: 6379) or {
	 	return ctx.json(ShortenResponse{
        	error: 'Redis failed to connect: $err'
    	})
	}

	redis.set(short_id, urls) or {
	 	return ctx.json(ShortenResponse{
			error: 'Failed to store URL in Redis: $err'
		})
	}

	redis.close() or {
		return ctx.json(ShortenResponse{
			error: 'Failed to close Redis connection: $err'
		})
	}
	
	return ctx.json(ShortenResponse{
		shortened_url: shortened_url
	})
}

@['/:short_id']
pub fn (app &App) redirect_url(mut ctx Context, short_id string) veb.Result {
	mut redis := vredis.new_client(host: '127.0.0.1', port: 6379) or {
		return ctx.json(ShortenResponse{
        	error: 'Redis failed to connect: $err'
    	})
	}

	url := redis.get(short_id) or {
	 	return ctx.json(ShortenResponse{
			error: 'Failed to fetch URL in Redis: $err'
		})
	}

	redis.close() or {
		return ctx.json(ShortenResponse{
			error: 'Failed to close Redis connection: $err'
		})
	}

	parsed_url := json.decode(Url, url) or {
		return ctx.json(ShortenResponse{
			error: 'Failed to parse URL data: $err'
		})
	}

	return ctx.redirect(parsed_url.original_url)
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.text('Hello from veb $app.domain')
}

fn main() {
	mut app := &App{
		domain: 'http://localhost:8000/'
	}
	veb.run[App, Context](mut app, 8000)
}
