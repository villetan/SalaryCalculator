module FileHelper
  require 'csv'
  @@hourly_wage = 3.75
  @@evening_wage = 1.15

  def handle_file(file)
    parsed = CSV.parse(file.read)
    employee_ids = parsed.drop(1).map{|x| x[1]}.uniq
    shifts = {}
    persons = {}
    employee_ids.each do |id|
      shifts[id] = []
      parsed.each do |shift|
        shifts[id] << shift if shift[1] == id
        persons[id] = shift[0] if shift[1] == id
      end
    end
    results ={}
    shifts.each do |id, shift_array|
      results[persons[id]] = count_salary(shift_array)
    end
    [parsed[1][2].split(".",2).last.gsub(".", "/"), results]
  end

  private

  def count_salary(shift_array)
    base_pay = 0
    evening_pay = 0
    overtime_pay = 0
    shift_array.each do |shift|
      start_shift, end_shift = get_start_and_end_date(shift)
      base_hours = time_diff(start_shift, end_shift)
      base_pay += (base_hours * @@hourly_wage).round(2)
      overtime_pay += overtime_salary(base_hours)
      evening_pay +=evening_salary(start_shift, end_shift)
    end
    salary = base_pay + evening_pay + overtime_pay
    [salary.round(2), base_pay.round(2), evening_pay.round(2), overtime_pay.round(2)]
  end

  def evening_salary(start_shift, end_shift)
    evening_start = Time.new(start_shift.year, start_shift.month, start_shift.day, 18)
    evening_start = Time.new(start_shift.year, start_shift.month, start_shift.day, 18).advance(days: -1) if start_shift.hour < 8
    evening_end = evening_start.advance(hours: 12)
    salary = 0
    if (start_shift >= evening_start and start_shift <= evening_end) or (end_shift >= evening_start and end_shift <= evening_end)
      night_hours=time_diff([start_shift, evening_start].max, [end_shift, evening_end].min)
      salary += night_hours * @@evening_wage
    end
    if time_diff(start_shift, end_shift) > 12 and end_shift > evening_start.advance(days: 1)
      salary += time_diff(end_shift, evening_start.advance(days: 1)) * @@evening_wage
    end
    salary.round(2)
    end

  def overtime_salary(base_hours)
    overtime_salary = 0
    if base_hours > 8
      hours = [base_hours - 8, 2].min
      overtime_salary += hours * 0.25 * @@hourly_wage
      if base_hours > 10
        hours = [base_hours - 10, 2].min
        overtime_salary += hours * 0.5 * @@hourly_wage
        if base_hours > 12
          hours = base_hours - 12
          overtime_salary += hours * @@hourly_wage
        end
      end
    end
    overtime_salary.round(2)
  end

  def get_start_and_end_date(shift)
    day, month, year = shift[2].split(".").map{|x| x.to_i}
    s_hour, s_minute = shift[3].split(":").map{|x| x.to_i}
    e_hour, e_minute = shift[4].split(":").map{|x| x.to_i}
    start = Time.new(year, month, day, s_hour, s_minute)
    if e_hour < s_hour
      stopped = start.advance(days: 1)
      stopped = stopped.change(:hour => e_hour, :min => e_minute)
    else
      stopped = start.change(:hour => e_hour, :min => e_minute)
    end
    [start, stopped]
  end

  def time_diff(start_time, end_time)
    diff_sec = (start_time - end_time).to_i.abs
    hours = diff_sec / 3600.0
    hours.round(2)
  end

end
