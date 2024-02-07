# frozen_string_literal: true

require 'hanami/api'
require 'hanami/middleware/body_parser'
require_relative './post_params_validator'

class Acerola < Hanami::API
  use Hanami::Middleware::BodyParser, :json

  post 'clients/:id/transacoes' do
    result = PostParamsValidator.exec(**env['router.params'])

    halt(400) unless result
  rescue ArgumentError => _e
    halt(400)
  end
end
