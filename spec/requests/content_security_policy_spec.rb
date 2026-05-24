# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy" do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it "includes a Content-Security-Policy header on the dashboard" do
    get "/visits"
    expect(response.headers["Content-Security-Policy"]).to be_present
  end

  it "sets default-src to self" do
    get "/visits"
    expect(response.headers["Content-Security-Policy"]).to include("default-src 'self'")
  end

  it "sets script-src with self and a nonce" do
    get "/visits"
    expect(response.headers["Content-Security-Policy"]).to match(%r{script-src 'self' 'nonce-[A-Za-z0-9+/=]+'})
  end

  it "sets style-src to allow unsafe-inline" do
    get "/visits"
    expect(response.headers["Content-Security-Policy"]).to include("style-src 'self' 'unsafe-inline'")
  end

  it "sets object-src to none" do
    get "/visits"
    expect(response.headers["Content-Security-Policy"]).to include("object-src 'none'")
  end

  it "includes a non-empty nonce in the script-src directive" do
    get "/visits"
    nonce = response.headers["Content-Security-Policy"][%r{'nonce-([A-Za-z0-9+/=]+)'}, 1]
    expect(nonce).to be_present
  end
end
