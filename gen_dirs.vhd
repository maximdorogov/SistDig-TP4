library work;
use work.cordic_lib.all;

entity gen_dirs is

    -- generic(
	-- 	---?
	-- );

	-- port(
    --     ---?
	-- );

end entity;

architecture gen_dirs_arq of gen_dirs is

    constant SCR_W : natural := 640;
    constant SCR_H : natural := 480;
    constant SIZE : natural := 160;

    integer dir : integer;

begin

    for pos in posiciones loop
        x := SCR_W / 2 - SIZE * pos(1); -- Redondear a integer
        y := SCR_H / 2 - SIZE * pos(2); -- same
        dir := x + y * SCR_W;
    end loop;

end;
