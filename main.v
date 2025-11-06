module main

import xiusin.vredis
import rand
import json
import veb

pub struct Context {
	veb.Context
}

pub struct App {
	pub:
		domain string
	mut:
		redis vredis.Redis
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

fn generate_short_id() string {
	return rand.string_from_set('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 6)
}

pub fn (mut app App) shorten(mut ctx Context) veb.Result {
	original_url := ctx.query['url'] or {
		return ctx.json(ShortenResponse{
        	error: 'Invalid URL format'
    	})
	}

	short_id := generate_short_id()
	shortened_url := app.domain + short_id

	urls := json.encode(Url{
		shortened_url: shortened_url
		original_url: original_url
	})

	app.redis.set(short_id, urls) or {
	 	return ctx.json(ShortenResponse{
			error: 'Failed to store URL in Redis: $err'
		})
	}

	return ctx.json(ShortenResponse{
		shortened_url: shortened_url
	})
}

@['/:short_id']
pub fn (mut app App) redirect_url(mut ctx Context, short_id string) veb.Result {
	url := app.redis.get(short_id) or {
	 	return ctx.json(ShortenResponse{
			error: 'Failed to fetch URL in Redis: $err'
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
	return $veb.html()
}

fn main() {
	mut redis := vredis.new_client(host: '127.0.0.1', port: 6379) or {
		panic(err)
	}

	mut app := &App{
		domain: 'http://localhost:8000/'
		redis: redis
	}

	veb.run[App, Context](mut app, 8000)
}
