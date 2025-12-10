# frozen_string_literal: true

module Base::Component::FormattingHelper
  # def format_datetime(datetime, user_time_zone: true, include_seconds: false)
  #   return nil if datetime.nil?

  #   raise "Must be DateTime or Time not #{datetime.class.name}" if !(datetime.is_a?(DateTime) || datetime.is_a?(Time))

  #   datetime = datetime.in_time_zone("Europe/Berlin") if user_time_zone

  #   format = include_seconds ? I18n.t("datetime.formats.with_seconds") : I18n.t("datetime.formats.short")
  #   datetime.strftime(format)
  # end

  # def format_date(date, user_time_zone: true, with_year: false)
  #   return nil if date.nil?

  #   unless date.is_a?(Date)
  #     raise "Must be Date not #{date.class.name}, if you really want to show a date " \
  #             "on a datetime, use .to_date() before passing."
  #   end

  #   date = date.in_time_zone("Europe/Berlin") if user_time_zone

  #   if with_year
  #     date.strftime(I18n.t("date.formats.long"))
  #   else
  #     date.strftime(I18n.t("date.formats.short"))
  #   end
  # end

  # def self.format_amount(amount)
  #   return amount.to_s if amount.blank?

  #   begin
  #     # Examples:
  #     # 1234,56
  #     # 1.234.567,89
  #     # 1.234,56
  #     # -1.234,56
  #     # 1.234,00 (two decimal places)

  #     # If amount is a string like "1234.56", convert to float
  #     money = Money.from_amount(amount.to_f, "EUR")
  #     # Format with symbol: false to omit the € sign, and use the correct delimiter/decimal
  #     money.format(symbol: false, thousands_separator: ".", decimal_mark: ",", no_cents_if_whole: false)
  #   rescue ArgumentError, TypeError
  #     # If parsing fails, return as string
  #     amount.to_s
  #   end
  # end
end
