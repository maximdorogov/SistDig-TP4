library work;
use work.cordic_lib.all;

entity rotador3d is
    generic(
		N: integer:= 32
	);
	port(
		alfa, beta, gama: in t_float
	);
end;

architecture rotador3d_arq of rotador3d is
    aux: t_pos;
    pix: t_vec;

begin
    for pos in posiciones loop  -- Rotar cada pîxel
        aux(3) <= pos(1);
        if (not isZero(alfa)) then ---implementar en PF
            aux(1 to 2) <= cordic(pos(2 to 3), alfa);
        else
            aux(1 to 2) <= pos(2 to 3);
        end if;

        aux(3) <= aux(1);
        if (not isZero(beta)) then
            aux(1 to 2) <= cordic(aux(2 to 3), beta);
        else
            aux(1 to 2) <= aux(2 to 3);
        end if;

        aux(3) <= aux(1);
        if (not isZero(gama)) then
            aux(1 to 2) <= cordic(aux(2 to 3), gama);
        else
            aux(1 to 2) <= aux(2 to 3);
        end if;

        -- Aplanar ahora?
        pix <= aux(2 to 3);
    end loop;
end;
