import Config

config :set_game, :timeout, 60 * 60 * 24 * 1_000

if config_env() == :test do
  config :set_game, :timeout, 100
end
