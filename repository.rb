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
