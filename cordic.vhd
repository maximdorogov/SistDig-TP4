natural N := 15;

type t_float is std_logic_vector(N-1 downto 0); ---revisar?
type t_coordenada is t_float;
type t_pos is array(1 to 3) of t_coordenada;
type t_mat_r is array(1 to 3) of t_coordenada;
type t_mat is array(1 to 3) of t_mat_r;

-- function matmul_3x3 (a : t_mat; b : t_mat) return t_mat is
--     variable i,j,k: integer := 0;
--     variable prod: t_mat := (others => (others => (others => '0')));
-- begin
--     for i in 1 to 3 loop
--         for j in 1 to 3 loop
--             for k in 1 to 3 loop
--                 prod(i)(j) := prod(i)(j) + (a(i)(k) * b(k)(j));
--             end loop;
--         end loop;
--     end loop;
--     return prod;
-- end matmul;
--
-- function matmul_3x1 (a : t_mat; v : t_pos) return t_pos is
--     variable i,j,k: integer := 0;
--     variable prod: t_pos := (others => (others => '0'));
-- begin
--     for i in 1 to 3 loop
--         for j in 1 to 3 loop
--             prod(i) := prod(i) + (a(i)(j) * v(j));
--         end loop;
--     end loop;
--     return prod;
-- end matmul;


-- beta: ángulo de rotación (en radianes)
function cordic (vector : t_pos, beta : t_float)
                return t_pos is
    constant P := 16; -- Cantidad de iteraciones, que determina la precisión
    --- Considerar mover a un paquete
    constant ANGLES: t_float := ( ..., ..., ...);
                    -- atan(2^-i) en formato correcto
-- 0.785398163397448, 0.463647609000806, 0.244978663126864, 0.124354994546761,
-- 0.0624188099959574, 0.0312398334302683, 0.0156237286204768, 0.00781234106010111,
-- 0.00390623013196697, 0.00195312251647882, 0.000976562189559319, 0.000488281211194898,
-- 0.000244140620149362, 0.00012207031189367, 6.10351561742088e-05, 3.05175781155261e-05,
-- 1.52587890613158e-05, 7.62939453110197e-06, 3.8146972656065e-06, 1.90734863281019e-06,
-- 9.53674316405961e-07, 4.76837158203089e-07, 2.38418579101558e-07, 1.19209289550781e-07,
-- 5.96046447753906e-08, 2.98023223876953e-08, 1.49011611938477e-08, 7.45058059692383e-09,
-- 3.72529029846191e-09, 1.86264514923096e-09, 9.31322574615479e-10, 4.65661287307739e-10,
-- 2.3283064365387e-10, 1.16415321826935e-10, 5.82076609134674e-11, 2.91038304567337e-11,
-- 1.45519152283669e-11, 7.27595761418343e-12, 3.63797880709171e-12, 1.81898940354586e-12

    constant K_VALUES: t_float := ( ..., ..., ...);
                    -- cumprod(1 ./ abs(1 + 1j*2.^(-(0:23)))) en formato correcto
-- 0.707106781186547, 0.632455532033676, 0.613571991077896, 0.608833912517752,
-- 0.607648256256168, 0.607351770141296, 0.607277644093526, 0.607259112298893,
-- 0.607254479332562, 0.607253321089875, 0.607253031529134, 0.607252959138945,
-- 0.607252941041397, 0.60725293651701, 0.607252935385914, 0.607252935103139,
-- 0.607252935032446, 0.607252935014772, 0.607252935010354, 0.607252935009249,
-- 0.607252935008973, 0.607252935008904, 0.607252935008887, 0.607252935008883,
-- 0.607252935008882, 0.607252935008881

    variable v, v_aux: t_pos := vector;
    variable sigma: integer := 1;
    variable angle_i: t_float := ANGLES(0);

begin
    if (beta < -pi/2 or beta > pi/2) then   ---Implementar comparación?
        if (beta < 0) then
            v <= cordic(beta + pi);
        else
            v <= cordic(beta - pi);
        end if;
        return -v;
    end if;

    for i in 0 to P-1 loop
        if (i > ANGLES'length - 1) then
            angle_i := angle_i / 2; ---o shift 1? -- Si superé la tabla, aproximo
        else
            angle_i := ANGLES(i);  -- Si no, tabla
        end if;

        if (beta < 0) then
            sigma = -1;
        else
            sigma = 1;
        end if;

        v_aux(0) <= v(0) - sigma * (v(1) * 2^(-i)); --- o pongo el shift directo?
        v_aux(1) <= sigma * (v(0) * 2^(-i)) + v(1);
        v <= v_aux;

        beta = beta - sigma * angle_i;  -- Actualizo ángulo beta faltante
    end for;

    -- Ajusto magnitud
    if (P > K_VALUES'length) then
        v <= v * K_VALUES(K_VALUES'length - 1);
    else
        v <= v * K_VALUES(P-1);
    end if;

    return v;
end function;


------------###########

    function v = cordic(beta,n)
    % This function computes v = [cos(beta), sin(beta)] (beta in radians)
    % using n iterations. Increasing n will increase the precision.

    if beta < -pi/2 || beta > pi/2
        if beta < 0
            v = cordic(beta + pi, n);
        else
            v = cordic(beta - pi, n);
        end
        v = -v; % flip the sign for second or third quadrant
        return
    end

    % Initialization of tables of constants used by CORDIC
    % need a table of arctangents of negative powers of two, in radians:
    % angles = atan(2.^-(0:27));
    angles =  [  ...
        0.78539816339745   0.46364760900081   0.24497866312686   0.12435499454676 ...
        0.06241880999596   0.03123983343027   0.01562372862048   0.00781234106010 ...
        0.00390623013197   0.00195312251648   0.00097656218956   0.00048828121119 ...
        0.00024414062015   0.00012207031189   0.00006103515617   0.00003051757812 ...
        0.00001525878906   0.00000762939453   0.00000381469727   0.00000190734863 ...
        0.00000095367432   0.00000047683716   0.00000023841858   0.00000011920929 ...
        0.00000005960464   0.00000002980232   0.00000001490116   0.00000000745058 ];
    % and a table of products of reciprocal lengths of vectors [1, 2^-2j]:
    % Kvalues = cumprod(1./abs(1 + 1j*2.^(-(0:23))))
    Kvalues = [ ...
        0.70710678118655   0.63245553203368   0.61357199107790   0.60883391251775 ...
        0.60764825625617   0.60735177014130   0.60727764409353   0.60725911229889 ...
        0.60725447933256   0.60725332108988   0.60725303152913   0.60725295913894 ...
        0.60725294104140   0.60725293651701   0.60725293538591   0.60725293510314 ...
        0.60725293503245   0.60725293501477   0.60725293501035   0.60725293500925 ...
        0.60725293500897   0.60725293500890   0.60725293500889   0.60725293500888 ];
    Kn = Kvalues(min(n, length(Kvalues)));

    % Initialize loop variables:
    v = [1;0]; % start with 2-vector cosine and sine of zero
    poweroftwo = 1;
    angle = angles(1);

    % Iterations
    for j = 0:n-1;
        if beta < 0
            sigma = -1;
        else
            sigma = 1;
        end
        factor = sigma * poweroftwo;
        % Note the matrix multiplication can be done using scaling by powers of two and addition subtraction
        R = [1, -factor; factor, 1];
        v = R * v; % 2-by-2 matrix multiply
        beta = beta - sigma * angle; % update the remaining angle
        poweroftwo = poweroftwo / 2;
        % update the angle from table, or eventually by just dividing by two
        if j+2 > length(angles)
            angle = angle / 2;
        else
            angle = angles(j+2);
        end
    end

    % Adjust length of output vector to be [cos(beta), sin(beta)]:
    v = v * Kn;
    return

    endfunction
    The two-by-two matrix multiplication can be carried out by a pair of simple shifts and adds.

        x = v[0] - sigma * (v[1] * 2^(-j));
        y = sigma * (v[0] * 2^(-j)) + v[1];
        v = [x; y];
