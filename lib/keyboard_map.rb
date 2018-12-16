# coding: utf-8
# frozen-string-literals: true

require "keyboard_map/version"
require 'set'

class KeyboardMap
  attr_reader :buf

  class Event
    attr_reader :modifiers,:key


    def initialize(key,*modifiers)
      @modifiers = Set[*modifiers.map(&:to_sym)]
      @key = key
    end

    def to_sym
      (modifiers.to_a.sort << key).join("_").to_sym
    end

    def ==(ev)
      case ev
      when Event
        return @modifiers == ev.modifiers && @key == ev.key
      when Symbol
        return self.to_sym == ev
      else
        return self.to_s == ev
      end
    end
  end

  SINGLE_KEY_EVENT = {
    "\t" => :tab,
    "\r" => :enter,
    "\u007F" => :backspace
  }.freeze

  # \e[ starts a CSI sequence. This maps the final character in the CSI
  # sequence to a key and how to interpret the parameters.
  CSI_BASIC_MAP = {
    "A"    => :up,
    "B"    => :down,
    "C"    => :right,
    "D"    => :left,
    "E"    => :keypad_5,
    "F"    => :end,
    "H"    => :home,
    "P"    => :f1,
    "Q"    => :f2,
    "R"    => :f3,
    "S"    => :f4,
  }.freeze

  # \e[{parameter1}{;...}~ from parameter1 => key
  CSI_TILDE_MAP = {
    "2"   => :insert,
    "3"   => :delete,
    "5"   => :page_up,
    "6"   => :page_down,
    "11"  => :f1,
    "12"  => :f2,
    "13"  => :f3,
    "14"  => :f4,
    "15"  => :f5,
    "17"  => :f6,
    "18"  => :f7,
    "19"  => :f8,
    "20"  => :f9,
    "21"  => :f10,
    "23"  => :f11,
    "24"  => :f12,
    "200" => :start_paste,
    "201" => :end_paste,
  }.freeze

  # Map of simple/non-parameterised escape sequences to symbols
  ESCAPE_MAP = {
    "\e[Z"    => Event.new(:tab,:shift),
    "\eOP"    => :f1,
    "\eOQ"    => :f2,
    "\eOR"    => :f3,
    "\eOS"    => :f4
  }.freeze

  CSI_FINAL_BYTE = 0x40..0x7e

  @@key_events = {}
  def self.event(key,*modifiers)
    e = Event.new(key,*modifiers)
    k = e.to_sym
    @@key_events[k] ||= e
    @@key_events[k]
  end

  def meta(key)
    self.class.event(key,:meta)
  end

  ESC = "\e"

  def initialize
    @tmp = ""
    @buf = ""
    @state = :text
  end

  def call(input)
    @buf << input
    run
  end

  def map_escape(seq)
    if sym = ESCAPE_MAP[seq]
      return sym
    end
    return Event.new(seq,:esc)
  end

  def ss3(ch)
    tmp = @tmp
    tmp << ch
    @tmp = ""
    @state = :text
    return map_escape(tmp)
  end

  def map_modifiers(mod)
    return [] if mod.nil?
    mod = mod.to_i - 1
    [].tap do |m|
      m << :shift if (mod & 1) == 1
      m << :meta  if (mod & 2) == 2
      m << :ctrl  if (mod & 4) == 4
    end
  end

  def map_csi(seq)
    if sym = ESCAPE_MAP[seq]
      return sym
    end
    final = seq[-1]
    params = String(seq[2..-2]).split(";")
    modifiers = []
    if final == "~"
      key = CSI_TILDE_MAP[params[0]]
      if key
        modifiers = map_modifiers(params[1])
      end
    else
      key = CSI_BASIC_MAP[final]
      modifiers = map_modifiers(params[1]) if key && params.first == "1" && params.size == 2
    end

    return Event.new(key,*Array(modifiers)) if key
    return Event.new((params << final).join("_"), :csi)
  end


  def csi(ch)
    @tmp << ch
    return nil if !CSI_FINAL_BYTE.member?(ch.ord)
    @state = :text
    tmp = @tmp
    @tmp = ""
    return map_csi(tmp)
  end

  def esc(ch)
    if ch == "["
      @state = :csi
      @tmp << ch
      return nil
    elsif ch == "O"
      @state = :ss3
      @tmp << ch
      return nil
    elsif ch == "\t"
      @state = :text
      @tmp = ""
      return meta(:tab)
    elsif ch == "\e"
      return :esc
    end
    @state = :text
    @tmp = ""
    return meta(ch)
  end

  def text(ch)
    if ch == ESC
      @state = :esc
      out = @tmp.empty? ? nil : @tmp
      @tmp = ESC.dup
      return out
    end

    if m = SINGLE_KEY_EVENT[ch]
      tmp = @tmp
      @tmp = ""
      return [self.class.event(m)] if tmp.empty?
      return [tmp, self.class.event(m)]
    end

    if ch.ord < 32
      tmp = @tmp
      @tmp = ""
      ev = self.class.event((ch.ord+96).chr,:ctrl)
      return [ev] if tmp.empty?
      return [tmp,ev]
    end

    @tmp << ch
    nil
  end

  def run
    out = []
    while !@buf.empty?
      ch = @buf.slice!(0)
      r = send(@state,ch)
      out.concat(Array(r)) if r
    end
    if !@tmp.empty? && @state == :text
      out << @tmp
      @tmp = ""
    end
    out
  end
end
