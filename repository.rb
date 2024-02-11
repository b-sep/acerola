# frozen_string_literal: true

require 'pg'

class Repository
  def self.find_customer(id)
    query = <<~SQL
      SELECT * FROM customers WHERE id = $1
    SQL

    result = conn.exec_params(query, [id]).first

    result&.transform_keys(&:to_sym)
  end

  def self.perform_transaction(customer_limit, params)
    return nil if params[:tipo] == 'd' && cannot_withdraw?(customer_limit, params)

    insert_transaction = <<~SQL
      INSERT INTO transactions(value, type, description, customer_id)
      VALUES ($1, $2, $3, $4)
      RETURNING id
    SQL

    update_balance = <<~SQL
      UPDATE balances
      SET value = value #{params[:tipo] == 'c' ? '+' : '-'} $1
      WHERE customer_id = $2
      RETURNING value
    SQL

    result_insert = conn.exec_params(insert_transaction, Array(params.values)).first
    result_update = conn.exec_params(update_balance, [params[:valor], params[:id]]).first

    result_insert&.merge(result_update)&.transform_keys(&:to_sym)
  end

  def self.statement(customer)
    query_transactions = <<~SQL
      SELECT value, type, description, created_at FROM transactions where customer_id = $1
      ORDER BY created_at DESC
      LIMIT 10
    SQL

    query_balance = <<~SQL
      SELECT value from balances where id = $1
    SQL

    result_transactions = conn.exec_params(query_transactions, [customer[:id]]).to_a
    result_balance = conn.exec_params(query_balance, [customer[:id]]).first

    {
      saldo: {
        total: result_balance['value'].to_i,
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

  def self.conn
    @conn ||= PG.connect(
      host: 'acerola_db',
      user: 'postgres',
      password: 'acerola',
      port: 5432,
      dbname: 'postgres'
    )
  end

  def self.cannot_withdraw?(customer_limit, params)
    query = <<~SQL
      SELECT value FROM balances where id = $1
    SQL

    result = conn.exec_params(query, [params[:id]]).first

    (result['value'].to_i - params[:valor].to_i) < -customer_limit.to_i
  end

  private_class_method :conn, :cannot_withdraw?
end
