# frozen_string_literal: true

require 'pg'
require 'connection_pool'

class Repository
  def self.find_customer(id)
    query = <<~SQL
      SELECT * FROM customers WHERE id = $1
    SQL

    result = pool.with do |conn|
      conn.exec_params(query, [id]).first
    end

    result&.transform_keys(&:to_sym)
  end

  def self.perform_transaction(params)
    result = {}

    insert_transaction = <<~SQL
      INSERT INTO transactions(value, type, description, customer_id)
      VALUES ($1, $2, $3, $4)
    SQL

    update_balance_customer = <<~SQL
      UPDATE customers
      SET balance = balance #{params[:tipo] == 'c' ? '+' : '-'} $1
      WHERE id = $2
      RETURNING max_limit, balance
    SQL

    pool.with do |c|
      c.transaction do |conn|
        # insert transaction
        conn.exec_params(insert_transaction, params.values)
        # update customer balance
        temp = conn.exec_params(update_balance_customer, [params[:valor], params[:id]]).first

        result = { limite: temp['max_limit'].to_i, saldo: temp['balance'].to_i }
      end
    end

    result
  rescue PG::CheckViolation => _e
    nil
  end

  def self.statement(customer)
    query_transactions = <<~SQL
      SELECT value, type, description, created_at FROM transactions where customer_id = $1
      ORDER BY created_at DESC
      LIMIT 10
    SQL

    result_transactions = pool.with do |c|
      c.transaction do |conn|
        conn.exec_params(query_transactions, [customer[:id]]).to_a
      end
    end

    {
      saldo: {
        total: customer[:balance].to_i,
        data_extrato: Time.now.to_s,
        limite: customer[:max_limit].to_i
      },
      ultimas_transacoes: if result_transactions.empty?
                            []
                          else
                            result_transactions.map do |t|
                              {
                                valor: t['value'].to_i,
                                tipo: t['type'],
                                descricao: t['description'],
                                realizado_em: t['created_at']
                              }
                            end
                          end
    }
  end

  def self.pool
    @pool ||= ConnectionPool.new(size: 10, timeout: 30) do
      PG.connect(
        host: 'acerola_db',
        user: 'postgres',
        password: 'acerola',
        port: 5432,
        dbname: 'postgres'
      )
    end
  end

  private_class_method :pool
end
