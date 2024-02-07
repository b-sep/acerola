# frozen_string_literal: true

module PostParamsValidator
  def self.exec(id:, valor:, tipo:, descricao:)
    return false if id.match?(/\D/)
    return false unless valor.instance_of?(Integer)
    return false if valor.zero? || valor.negative?
    return false unless tipo.instance_of?(String)
    return false unless %w[c d].include?(tipo.downcase)
    return false unless descricao.instance_of?(String)
    return false if descricao.empty? || descricao.size > 10

    true
  end
end
