module CurrencyConverter
  class Currency
     AVAILABLE_CURRENCY = [ 'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'GBP', 'HKD',
                            'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK',
                            'NZD', 'PHP', 'PLN', 'RON', 'RUB', 'SEK', 'SGD', 'THB', 'TRY', 'USD',
                            'ZAR', 'EUR' ]

    #  Public: Build currency object with rules.
    #
    #  total_currency - (Fixnum)  - Total currency to convert
    #  options - (Hash)  - from, to (optinal), at (optional)
    #
    # Examples
    #
    #   convert(12, from: 'EUR', to: 'EUR', at: '2015-07-12')
    #   # => <#CurrencyConverter::Currency @total_currency=12, @currency_from='EUR', @currency_to='EUR', @at='2015-07-12'>
    #
    #   convert(12, from: 'EUR', to: 'EUR')
    #   # => <#CurrencyConverter::Currency @total_currency=12, @currency_from='EUR', @currency_to='EUR', @at=Date.today>
    #
    #   convert(12, from: 'EUR')
    #   # => <#CurrencyConverter::Currency @total_currency=12, @currency_from='EUR', @currency_to='EUR', @at=Date.today>
    #
    #   convert(12, from: 'USD', to: 'EUR')
    #   # => <#CurrencyConverter::Currency @total_currency=12, @currency_from='USD', @currency_to='EUR', @at=Date.today>
    #
    # Returns <#CurrencyConverter::Currency...>

    def self.convert(total_currency, options = {})
      at    = build_currency_rate_date(options[:at])
      from  = build_from_currency(options.fetch(:from))
      to    = build_to_currency(from, options[:to])

      new(total_currency: total_currency, from: from, to: to, at: at)
    end

    def initialize(params = {})
      @total_currency = params.fetch(:total_currency)
      @currency_from = params.fetch(:from)
      @currency_to = params.fetch(:to)
      @currency_rate_date = params.fetch(:at)
    end

    # Public: Get rate 
    #
    # Examples
    #
    #   rate
    #   # => 1
    #
    # Returns Fixnum.
    def rate
      @rate = if @currency_from == @currency_to
                1
              else
                FixerHttpClient.get_rate(@currency_rate_date, @currency_from)[@currency_to.to_sym]
              end
    end

    # Public: Calculation total_currency in new currency
    #
    # Examples
    #
    #   take
    #   # => 12
    #
    # Returns Fixnum.
    def take
      @total_currency * rate
    end

    private

    def self.build_currency_rate_date(date = '')
      if date.nil?
        Date.today.to_s
      else
        date
      end
    end

    def self.build_from_currency(from_currency)
      if AVAILABLE_CURRENCY.include?(from_currency)
        from_currency
      else
        raise CurrencyConverter::CurrencyUnknown
      end
    end

    def self.build_to_currency(from_currency, to_currency)
      if to_currency.empty?
        from_currency
      elsif AVAILABLE_CURRENCY.include?(to_currency)
        to_currency
      else
        raise CurrencyConverter::CurrencyUnknown
      end
    end
  end
end
