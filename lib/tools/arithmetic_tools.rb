class AddTool < FastMcp::Tool
  description "Add numbers together with precise decimal rounding (for expense calculations)"

  arguments do
    required(:numbers).array(:float).description("Numbers to add (minimum 1)")
    optional(:decimal_places).filled(:integer).description("Decimal precision (default 2)")
  end

  def call(numbers:, decimal_places: 2)
    Validators.in_range!(decimal_places, :decimal_places, min: 0)
    raise ValidationError.new("At least 1 number is required", field: :numbers) if numbers.empty?
    result = numbers.sum
    { result: result.round(decimal_places), result_formatted: result.round(decimal_places).to_s, operands: numbers, operation: 'add' }
  end
end

class SubtractTool < FastMcp::Tool
  description "Subtract numbers sequentially: first - second - third... (for expense calculations)"

  arguments do
    required(:numbers).array(:float).description("Numbers to subtract (minimum 2)")
    optional(:decimal_places).filled(:integer).description("Decimal precision (default 2)")
  end

  def call(numbers:, decimal_places: 2)
    Validators.in_range!(decimal_places, :decimal_places, min: 0)
    raise ValidationError.new("At least 2 numbers are required", field: :numbers) if numbers.length < 2
    result = numbers[1..].reduce(numbers[0]) { |acc, n| acc - n }
    { result: result.round(decimal_places), result_formatted: result.round(decimal_places).to_s, operands: numbers, operation: 'subtract' }
  end
end

class MultiplyTool < FastMcp::Tool
  description "Multiply numbers together (for expense calculations)"

  arguments do
    required(:numbers).array(:float).description("Numbers to multiply (minimum 2)")
    optional(:decimal_places).filled(:integer).description("Decimal precision (default 2)")
  end

  def call(numbers:, decimal_places: 2)
    Validators.in_range!(decimal_places, :decimal_places, min: 0)
    raise ValidationError.new("At least 2 numbers are required", field: :numbers) if numbers.length < 2
    result = numbers.reduce(:*)
    { result: result.round(decimal_places), result_formatted: result.round(decimal_places).to_s, operands: numbers, operation: 'multiply' }
  end
end

class DivideTool < FastMcp::Tool
  description "Divide numbers sequentially: first / second / third... (for expense calculations)"

  arguments do
    required(:numbers).array(:float).description("Numbers to divide (minimum 2)")
    optional(:decimal_places).filled(:integer).description("Decimal precision (default 2)")
  end

  def call(numbers:, decimal_places: 2)
    Validators.in_range!(decimal_places, :decimal_places, min: 0)
    raise ValidationError.new("At least 2 numbers are required", field: :numbers) if numbers.length < 2
    raise ValidationError.new("Cannot divide by zero") if numbers[1..].any?(&:zero?)
    result = numbers[1..].reduce(numbers[0].to_f) { |acc, n| acc / n }
    { result: result.round(decimal_places), result_formatted: result.round(decimal_places).to_s, operands: numbers, operation: 'divide' }
  end
end

class ModuloTool < FastMcp::Tool
  description "Get remainder of division (for expense splitting calculations)"

  arguments do
    required(:a).filled(:float).description("Dividend")
    required(:b).filled(:float).description("Divisor")
    optional(:decimal_places).filled(:integer).description("Decimal precision (default 2)")
  end

  def call(a:, b:, decimal_places: 2)
    Validators.in_range!(decimal_places, :decimal_places, min: 0)
    raise ValidationError.new("Cannot divide by zero") if b.zero?
    result = a % b
    { result: result.round(decimal_places), result_formatted: result.round(decimal_places).to_s, operands: [a, b], operation: 'modulo' }
  end
end
