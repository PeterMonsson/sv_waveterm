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

class sv_waveterm_element;
   string name;
   int    bits;
   int    size;
   
   logic [63:0] values[];
   int          counter;
   
   function new(string name, int bits);
      this.name = name;
      this.bits = bits;
      counter = 0;
   endfunction

   function void record(logic [63:0] value);
      values[counter%size] = value;
      counter++;
   endfunction

   function void build(int size);
      this.size = size;
      values = new[size];
   endfunction
   
   function string sprint(int n_size, int e_size);
      int       min_count;
      string    section;
      string    empty_section;
      string    empty_name;
      string    padded_name;
      min_count = counter >= size ? counter - size : 0;

      section = "";
      empty_section = "";
      for (int i = 0; i < e_size; i++) begin
         section = {section, "-"};
         empty_section = {empty_section, " "};
      end
      empty_name = "";
      for (int i = 0; i < n_size+1; i++) begin
         empty_name = {empty_name, " "};
      end

      padded_name = name;
      for (int i = name.len(); i < n_size+1; i++) begin
         padded_name = {padded_name, " "};
      end

      
      if (bits == 1) begin
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
      string sprint;
      sprint = {name, " "}; //TODO: or - or +? I don't know
      for (int i = min_counter; i < counter; i++) begin
         if (i != min_counter) begin
            if (values[(i-1)%size] === values[i%size]) begin
               if (values[i%size] === val) begin
                  sprint = {sprint, "-"};
               end else begin
                  sprint = {sprint, " "};
               end
            end else begin
               sprint = {sprint, "+"};
            end
         end
         if (values[i%size] === val) begin
            sprint = {sprint, section};
         end else begin
            sprint = {sprint, empty_section};
         end
      end
      if (values[(counter-1)%size] === val) begin
         sprint = {sprint, "-"};
      end else begin
         sprint = {sprint, " "};
               end
      return sprint;
   endfunction

   function string sprint_line2(int min_counter, string name, string section);
      string sprint;
      sprint = {name, "+"};
      for (int i = min_counter; i < counter; i++) begin
         if (i != min_counter) begin
            if (values[(i-1)%size] === values[i%size]) begin
               sprint = {sprint, "-"};
            end else begin
               sprint = {sprint, "+"};
            end
         end
         
         sprint = {sprint, section};
      end
      sprint = {sprint, "+"};
      return sprint;
   endfunction

   function string get_padded_value(int index, int e_size);
      string str;
      str = $sformatf("%0h", values[index%size]);
      for (int i = str.len(); i < e_size; i++) begin
         str = {str, " "};
      end
      return str;
   endfunction
   
   function string sprint_line3(int min_counter, string name, string section, int e_size);
      string sprint;
      sprint = {name, "|"};
      for (int i = min_counter; i < counter; i++) begin
         if (i != min_counter) begin
            if (values[(i-1)%size] === values[i%size]) begin
               sprint = {sprint, " "};
               sprint = {sprint, section};
            end else begin
               sprint = {sprint, "|"};
               sprint = {sprint, get_padded_value(i, e_size)};
            end
         end else begin
            sprint = {sprint, get_padded_value(i, e_size)};
         end
      end
      sprint = {sprint, "|"};
      return sprint;
   endfunction
endclass

class sv_waveterm;
   sv_waveterm_element elements[$];
   string clk_name;
   
   function new(string clk_name);
      this.clk_name = clk_name;
      elements = '{};
   endfunction

   function void add(string name, int bits);
      sv_waveterm_element e;
      e = new(name, bits);
      elements.push_back(e);
   endfunction

   function void build();
      for (int i = 0; i < elements.size(); i++) begin
        elements[i].build(8); //TODO: stop hardcoding to 8
      end
   endfunction
   
   //TODO: accidentally quadratic
   function void record(string name, logic [63:0] value);
      for (int i = 0; i < elements.size(); i++) begin
         if (0 == name.compare(elements[i].name)) begin
            elements[i].record(value);
         end
      end
   endfunction

   function int get_largest_name();
      int size = clk_name.len();
      for (int i = 0; i < elements.size(); i++) begin
         if (elements[i].bits > size) begin
            size = elements[i].name.len();
         end
      end
      return size;
   endfunction

   function int get_largest_display_size();
      int size = 0;
      for (int i = 0; i < elements.size(); i++) begin
         if (elements[i].bits > size) begin
            size = elements[i].bits;
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
     sprint = sprint_clk(n_size, e_size, c_size); //TODO: move counter to parent, so that we only have one. This will break future optimizations, but improve memory consumption now.
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
      string sprint;
      
      //TODO: refactor to common helper methods
      padded_name = clk_name;
      for (int i = clk_name.len(); i < n_size+1; i++) begin
         padded_name = {padded_name, " "};
      end

      section = "";
      empty_section = "";
      for (int i = 0; i < e_size/2; i++) begin
         section = {section, "-"};
         empty_section = {empty_section, " "};
      end

      section2 = "";
      empty_section2 = "";
      for (int i = 0; i < e_size-e_size/2; i++) begin
         section2 = {section2, "-"};
         empty_section2 = {empty_section2, " "};
      end

      empty_name = "";
      for (int i = 0; i < n_size+1; i++) begin
         empty_name = {empty_name, " "};
      end

      sprint = empty_name;
      for (int i = 0; i < size; i++) begin
	 sprint = {sprint, "+", section, "+", empty_section};
      end
      sprint = {sprint, "+\n"}; 
      sprint = {sprint, padded_name}; 
      for (int i = 0; i < size; i++) begin
	 sprint = {sprint, "+", empty_section, "+", section};
      end
      sprint = {sprint, "+\n"}; 
      return sprint;
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
    _waves.add(`"id`", $bits(id)); \
    fork begin \
      forever begin \
        @(posedge ___waveterm_clk) \
        _waves.record(`"id`", id); \
      end \
    end join_none \
  end

`define sv_waveterm_end \
      _waves.build(); \
    end \
  end endgenerate

`endif
