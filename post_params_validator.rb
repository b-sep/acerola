# frozen_string_literal: true

module PostParamsValidator
  def self.exec(**params)
    return false unless params[:id] && params[:valor] && params[:tipo] && params[:descricao]

    id = params[:id]
    value = params[:valor]
    type = params[:tipo]
    description = params[:descricao]

    return false if id.match?(/\D/)
    return false unless value.instance_of?(Integer)
    return false if value.zero? || value.negative?
    return false unless type.instance_of?(String)
    return false unless %w[c d].include?(type)
    return false unless description.instance_of?(String)
    return false if description.empty? || description.size > 10

    true
  end
end
