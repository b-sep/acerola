# frozen_string_literal: true

require 'hanami/api'
require 'hanami/middleware/body_parser'
require_relative './post_params_validator'
require_relative './repository'

class Acerola < Hanami::API
  use Hanami::Middleware::BodyParser, :json

  post 'clientes/:id/transacoes' do
    params = env['router.params']
    halt(422) unless PostParamsValidator.exec(**params)
    customer = Repository.find_customer(params[:id])
    halt(404) unless customer

    result = Repository.perform_transaction(params)

    result ? [200, {}, json(result)] : 422
  end

  get 'clientes/:id/extrato' do
    params = env['router.params']
    halt(422) if params[:id].match?(/\D/)

    customer = Repository.find_customer(params[:id])
    halt(404) unless customer

    [200, {}, json(Repository.statement(customer))]
  end
end
