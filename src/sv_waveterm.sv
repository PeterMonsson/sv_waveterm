// sv_waveterm (c) by Peter Monsson
//
// This work is licensed under the Creative Commons 
// Attribution-NonCommercial-ShareAlike 4.0 International License. 
// To view a copy of this license, visit 
// http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to 
// Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. 
//
// Inspired by hardcaml_waveterm by Jane Street
//
// Usage: Go to https://github.com/PeterMonsson/sv_waveterm/ to see 
// documentation, examples, etc.

`ifndef __SV_WAVETERM__
`define __SV_WAVETERM__

// verilator lint_off DECLFILENAME
class sv_waveterm_helpers;
// verilator lint_on DECLFILENAME
   static function string get_padded_string(string s, int size);
      get_padded_string = s;
      for (int i = s.len(); i < size; i++) begin
         get_padded_string = {get_padded_string, " "};
      end
   endfunction

   static function string repeat_string(string s, int times);
      repeat_string = "";
      for (int i = 0; i < times; i++) begin
         repeat_string = {repeat_string, s};
      end
   endfunction
endclass


class sv_waveterm_element;
   string m_name;
   int    m_bits;
   int    m_size;
   
   logic [63:0] values[];
   int          counter;
   
   function new(string name, int bits);
      m_name = name;
      m_bits = bits;
      counter = 0;
   endfunction

   function void record(logic [63:0] value);
      values[counter%m_size] = value;
      counter++;
   endfunction

   function void build(int size);
      m_size = size;
      values = new[size];
   endfunction
   
   function string sprint(int n_size, int e_size);
      int       min_count;
      string    section;
      string    empty_section;
      string    empty_name;
      string    padded_name;
      min_count = counter >= m_size ? counter - m_size : 0;

      section = sv_waveterm_helpers::repeat_string("-", e_size);
      empty_section = sv_waveterm_helpers::repeat_string(" ", e_size);

      empty_name = sv_waveterm_helpers::get_padded_string("", n_size+1);
      padded_name = sv_waveterm_helpers::get_padded_string(m_name, n_size+1);
      
      if (m_bits == 1) begin
         sprint = sprint_line(min_count, empty_name, 1'b1, section, empty_section);
         sprint = {sprint, "\n"};
         sprint = {sprint, sprint_line(min_count, padded_name, 1'b0, section, empty_section)};
         sprint = {sprint, "\n"};
      end else begin
         sprint = sprint_line2(min_count, empty_name, section);
         sprint = {sprint, "\n"};
         sprint = {sprint, sprint_line3(min_count, padded_name, empty_section, e_size)};
         sprint = {sprint, "\n"};
         sprint = {sprint, sprint_line2(min_count, empty_name, section)};
         sprint = {sprint, "\n"};
      end
   endfunction

   function string sprint_line(int min_counter, string name, bit val, string section, string empty_section);
      string result;
      result = {name, " "}; //TODO: or - or +? I don't know
      for (int i = min_counter; i < counter; i++) begin
         if (i != min_counter) begin
            if (values[(i-1)%m_size] === values[i%m_size]) begin
               if (values[i%m_size][0] === val) begin
                  result = {result, "-"};
               end else begin
                  result = {result, " "};
               end
            end else begin
               result = {result, "+"};
            end
         end
         if (values[i%m_size][0] === val) begin
            result = {result, section};
         end else begin
            result = {result, empty_section};
         end
      end
      if (values[(counter-1)%m_size][0] === val) begin
         result = {result, "-"};
      end else begin
         result = {result, " "};
               end
      return result;
   endfunction

   function string sprint_line2(int min_counter, string name, string section);
      string result;
      result = {name, "+"};
      for (int i = min_counter; i < counter; i++) begin
         if (i != min_counter) begin
            if (values[(i-1)%m_size] === values[i%m_size]) begin
               result = {result, "-"};
            end else begin
               result = {result, "+"};
            end
         end
         
         result = {result, section};
      end
      result = {result, "+"};
      return result;
   endfunction

   function string get_padded_value(int index, int e_size);
      string str;
      str = $sformatf("%0h", values[index%m_size]);
      for (int i = str.len(); i < e_size; i++) begin
         str = {str, " "};
      end
      return str;
   endfunction
   
   function string sprint_line3(int min_counter, string name, string section, int e_size);
      string result;
      result = {name, "|"};
      for (int i = min_counter; i < counter; i++) begin
         if (i != min_counter) begin
            if (values[(i-1)%m_size] === values[i%m_size]) begin
               result = {result, " "};
               result = {result, section};
            end else begin
               result = {result, "|"};
               result = {result, get_padded_value(i, e_size)};
            end
         end else begin
            result = {result, get_padded_value(i, e_size)};
         end
      end
      result = {result, "|"};
      return result;
   endfunction
endclass

class sv_waveterm;
   sv_waveterm_element elements[$];
   string m_clk_name;
   
   function new(string clk_name);
      m_clk_name = clk_name;
      elements = '{};
   endfunction

   function sv_waveterm_element add(string name, int bits);
      sv_waveterm_element e;
      e = new(name, bits);
      elements.push_back(e);
      return e;
   endfunction

   function void build();
      for (int i = 0; i < elements.size(); i++) begin
        elements[i].build(8); //TODO: stop hardcoding to 8
      end
   endfunction

   function int get_largest_name();
      int size = m_clk_name.len();
      for (int i = 0; i < elements.size(); i++) begin
         if (elements[i].m_name.len() > size) begin
            size = elements[i].m_name.len();
         end
      end
      return size;
   endfunction

   function int get_largest_display_size();
      int size = 0;
      for (int i = 0; i < elements.size(); i++) begin
         if (elements[i].m_bits > size) begin
            size = elements[i].m_bits;
         end
      end
      return (size-1)/4+1;
   endfunction

   function int get_largest_counter();
      int counter = 0;
      for (int i = 0; i < elements.size(); i++) begin
        if (elements[i].counter > counter) begin
          counter = elements[i].counter;
         end
      end
      return counter;
   endfunction

  
   function string sprint();
      int n_size = get_largest_name();
      int e_size = get_largest_display_size();
      int c_size = get_largest_counter();
      e_size = e_size > 3 ? e_size : 3;
      c_size = c_size > 8 ? 8 : c_size; //TODO: Stop hardcoding to 8
     sprint = sprint_clk(n_size, e_size-1, c_size); //TODO: move counter to parent, so that we only have one. This will break future optimizations, but improve memory consumption now.
      for (int i = 0; i < elements.size(); i++) begin
         sprint = {sprint, elements[i].sprint(n_size, e_size)};
      end
      return sprint;
   endfunction

   function string sprint_clk(int n_size, int e_size, int size);
      string empty_name;
      string padded_name;
      string section;
      string empty_section;
      string section2;
      string empty_section2;
      string result;
      
      empty_name = sv_waveterm_helpers::get_padded_string("", n_size+1);
      padded_name = sv_waveterm_helpers::get_padded_string(m_clk_name, n_size+1);

      section = sv_waveterm_helpers::repeat_string("-", e_size/2);
      empty_section = sv_waveterm_helpers::repeat_string(" ", e_size/2);

      section2 = sv_waveterm_helpers::repeat_string("-", e_size-e_size/2);
      empty_section2 = sv_waveterm_helpers::repeat_string(" ", e_size-e_size/2);

      result = empty_name;
      for (int i = 0; i < size; i++) begin
	 result = {result, "+", section, "+", empty_section2};
      end
      result = {result, "+\n"}; 
      result = {result, padded_name}; 
      for (int i = 0; i < size; i++) begin
	 result = {result, "+", empty_section, "+", section2};
      end
      result = {result, "+\n"}; 
      return result;
   endfunction
endclass

`define sv_waveterm_begin(id, clk) \
  sv_waveterm id; \
  generate begin : gen_``id \
    wire ___waveterm_clk = clk; \
    initial begin \
      sv_waveterm _waves; \
      id = new(`"clk`"); \
      _waves = id;

//TODO: create a $bits sized element with a generic name here.
`define sv_waveterm_int(id) \
  begin \
    sv_waveterm_element _e; \
    _e = _waves.add(`"id`", $bits(id)); \
    fork begin \
      forever begin \
        @(posedge ___waveterm_clk) \
        _e.record(64'(id)); \
      end \
    end join_none \
  end

`define sv_waveterm_end \
      _waves.build(); \
    end \
  end endgenerate

`endif
