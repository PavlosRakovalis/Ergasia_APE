clc
clear
close all

% AEM:6930

Tanaf = 100;  %Celsius
Tznx = 45;  
Tk =  [4.2 5 7.5 11.5 15.7 19.8 22.2 22.7 20.2 15.9 10.8 6.6] ; %  "θερμοκρασία νερού δικτύου" πίνακας 6.2
Ta = [4 6.3 9.7 14.4 19.7 24.4 26.5 25.6 21.7 15.7 9.4 4.8] ; % πίνακας 3.1 Μέση Μηνιαία θερμοκρασία περιβάλλοντος"
FR_mult_Ul = 1.8; % πινακας 5.10 (α1) (Κενού)
FR_mult_tan = 0.7; % πινακας 5.10 (η0) (Κενού)
FRdot_div_FR = 0.95;  %FR'/FR
ta_div_tan = 0.99; %τα/ταn
k1 = 1; % έστω Μ = 75 
k3 = 1;
Ta_dot = [5.2 7.7 11.2 16 21.4 26.1 28.3 27.5 23.6 17.4 10.8 6]; % Celsius "Μέση μηνιαία θερμοκρασία κατά τη διάρκεια της ημέρας (Σέρρες πίνακας 3.2 , Δεκέμβρης) " 
k2 = (11.6 + 1.18*Tznx + 3.86*Tk - 2.32*Ta)./(100-Ta);
p = 1000; %kg/m^3 
HKznx = 80*300; % "Μέση ημερήσια κατανάλωση ζεστού νερού" , πίνακας 2.5, αρ. κλινών = 300
Cp = 4180; % J/kg*K 

dt = [2678400 2419200 2678400 2592000 2678400 2592000 2592000 2678400 2592000 2592000 2592000 2678400];

N = [31 28 31 30 31 30 31 31 30 31 30 31] ; %αριθμός ημερών κάθε μήνα 

Hb = [51 68 106 141 181 203 210 188 141 95 57 44]*3600*10^3 ; %Μέση μηνιαία ηλιακή ακτινοβολία, "Σέρρες , σελ.70"
 
hls = 1 - 11.5/100 ; %"ποσοστό απωλειών κεντρικού δικτύου διανομής", μόνωση κτηρίου αναφοράς, με ανακυκλοφορία, σελ30 οδηγίες

L = (N*HKznx*p*Cp.*(Tznx-Tk)/hls)*10^(-3);
     Lsum = sum(L);

% Αρχικοποίηση αναζήτησης
Ac_max = 1e6;

Ac_found = NaN;

% --------------------------------------------------------------------------

% erwtimama 1   Apaιtoumeni epifaneia syllektwn gia etisio f = 0.6

for Ac = 0:0.25:Ac_max
   
     X = (Ac./L).*FR_mult_Ul.*FRdot_div_FR.*(Tanaf - Ta).*dt.*k1.*k2;

     Y = (Ac./L).*FR_mult_tan.*FRdot_div_FR.*ta_div_tan.*Hb.*k3;

     f = 1.029*Y - 0.065*X - 0.245.*(Y.^2) + 0.0018.*(X.^2) + 0.0215.*(Y.^3);




     % === ΤΡΟΠΟΠΟΙΗΣΗ: Ορισμός μέγιστης μηνιαίας κάλυψης f = 1 ===
     f(f > 1) = 1; 
     
     % Σημείωση: Δεν χρειάζεται πλέον ο έλεγχος f_sum == 0 αφού το f είναι >= 0
     

     Li_mult_fi = L.*f ;
     SF =  sum(Li_mult_fi)/sum(L);
     
     if SF >= 0.6
        Ac_found = Ac;
        break
    end
end

% Εμφάνισε αποτέλεσμα
if ~isnan(Ac_found)
    fprintf('Ac = %d με SF = %.4f\n', Ac_found, SF);
else
    fprintf('Δεν βρέθηκε Ac <= %d που να δίνει SF >= 0.6. Τελευταίο SF = %.4f\n', Ac_max, SF);
end

%--------------------------------------------------------------------------------------------

% erwtimama 2    (Ypologismos ogkou dexamenis apothikeysis )

V_dexamenis = 75*Ac ; % "lt"

 Vd = HKznx ;  
 Cp1 = 4.18 ;   % kJ/(kg*K)
 Tcw = [4.2 5 7.5 11.5 15.7 19.8 22.2 22.7 20.2 15.9 10.8 6.6]; % "θερμοκρασία νερού δικτύου" πίνακας 6.2
 p_den = 1 ;   % kg/lt
 
 Qdem_HW_dot = (Vd*(Cp1/3600)*p_den*(45 - min(Tcw)))*(1/hls); 
 QHW_dot = Qdem_HW_dot/5 %KWh 

 %--------------------------------------------------------------------------------------------
  
 % erwtimama 3   (Ypologismos etisiws ekpompwn CO2 prin kai meta tin egkatastasi iliakou systimatos)


 h_boiler = 0.8 ; % "σελίδα 34 οδηγός εργασίας"
 EF_CO2 = 0.264 ;

 Qdem_HW = (Vd*(Cp1/3600)*p_den*(45 - Tcw))*(1/hls);
 
 E_fuel = N.*Qdem_HW/h_boiler ;
 mCo2 = EF_CO2*E_fuel ;
 

% η αντλία θερμότητας καλύπτει το 40 % φορτίου 
 COP = 2.7 ;  

 E_el =   N.*Qdem_HW.* (1-f)/COP ;
 EF_el = 0.989; 
 mCo2_new = EF_el*E_el ;

 Dm_Co2 = (sum(mCo2) - sum(mCo2_new)) 

 %--------------------------------------------------------------------------------------------

 
% erwtimama 4  (Ypologismos ogkou dexamenis diepoxiakis apothikeysis)
 
L_dec = N(12)*HKznx*p*Cp*(Tznx-Tk(12))*10^(-3);

Vtank = L_dec/(p*Cp*(45 - Tcw(12))) %lt

% Eύρεση Nέου Αc :

% Αρχικοποίηση αναζήτησης
Ac_new_max = 1e6;

Ac_new_found = NaN;

for Ac_new = 0:0.25:Ac_new_max
   
     X_new = (Ac_new./L).*FR_mult_Ul.*FRdot_div_FR.*(Tanaf - Ta).*dt.*k1.*k2;

     Y_new = (Ac_new./L).*FR_mult_tan.*FRdot_div_FR.*ta_div_tan.*Hb.*k3;

     f_new = 1.029*Y_new - 0.065*X_new - 0.245.*(Y_new.^2) + 0.0018.*(X_new.^2) + 0.0215.*(Y_new.^3);
     f_sum = sum(f_new) ;
     
     % Ασφάλεια: αν f_sum == 0, προχώρησε στο επόμενο Ac (αποφυγή διαίρεσης/NaN)
    if f_sum == 0
        continue
    end

    % Υπολογισμός περίσσειας ενέργειας για όλους τους μήνες με f_new > 1
    excess_energy = (f_new - 1) .* L;
    excess_energy(f_new <= 1) = 0;  % Μηδενισμός για μήνες χωρίς υπερπαραγωγή
    Qsummer_excess = sum(excess_energy);
    Qdecember = L(12);
    
    % Έλεγχος αν καλύπτεται η ζήτηση του Δεκεμβρίου
    if Qsummer_excess >= Qdecember
        Ac_new_found = Ac_new
        break
    end
end

% Υπολογισμός ενέργειας που παράγεται από το ηλιακό σύστημα κάθε μήνα
Q_solar = f_new .* L;  % Ενέργεια που παράγει το ηλιακό σύστημα
Q_solar(12) = 0;  % Set December energy to zero for plotting

% Δημιουργία γραφήματος
figure;
bar(1:12, Q_solar);
hold on;
plot(1:12, L, 'r--o', 'LineWidth', 2, 'MarkerSize', 6);
hold off;

% Προσθήκη ετικετών και τίτλου
xlabel('Μήνας');
ylabel('Ενέργεια (kWh)');
title('Ενέργεια Ηλιακού Συστήματος vs Ενεργειακές Ανάγκες ανά Μήνα');
legend('Ενέργεια Ηλιακού Συστήματος', 'Ενεργειακές Ανάγκες', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});








% Γράφημα του παράγοντα f για κάθε μήνα
f_new_plot = f_new;
f_new_plot(12) = 0;  % Set December f value to zero for plotting

figure;
bar(1:12, f_new_plot);
hold on;
yline(1, 'r--', 'LineWidth', 2);
hold off;

% Προσθήκη ετικετών και τίτλου
xlabel('Μήνας');
ylabel('Παράγοντας f');
title('Παράγοντας f ανά Μήνα');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});
ylim([0 max(f_new_plot)*1.1]);





% ============================================================================
% Erotima 5
% ============================================================================
%
% Ουσιαστικά θα βάλουμε ολόκληρο τον κώδικα από την αρχή
%
% Αλλαγές:
%   1) Οι μήνες από τους οποίους παίρνουμε υπερπαραγωγή ενέργειας (f > 1) 
%      θα χρησιμοποιηθούν για την κάλυψη μέρος των αναγκών του μήνα Ιανουαρίου 
%      ο οποίος έχει την χαμηλότερη θερμοκρασία νερού δικτύου και άρα μας 
%      συμφέρει περισσότερο η χρήση του ζεστού καλοκαιρινού νερού εκεί
%
%   2) Το 1 συνεπάγεται ότι θα αλλάξει και ο όγκος της δεξαμενής 
%      διεποχιακής αποθήκευσης
%
% ============================================================================

% Βήμα 1: Υπολογισμός συνολικού υπερπαραγόμενου ζεστού νερού και συνεπώς και νέου όγκου διεποχιακής αποθήκευσης.

% Βήμα 1: Εντοπισμός μηνών με f > 1 και υπολογισμός υπερπαραγωγής νερού
excess_water_volume = zeros(1, 12);
for i = 1:12
    if f_new(i) > 1
        % Υπολογισμός υπερπαραγωγής ενέργειας για τον μήνα i
        excess_energy_i = (f_new(i) - 1) * L(i);
        
        % Μετατροπή υπερπαραγωγής ενέργειας σε όγκο νερού
        % Q = V * p * Cp * ΔT => V = Q / (p * Cp * ΔT)
        % ΔT = Tznx - Tk(i) για τον μήνα i
        excess_water_volume(i) = excess_energy_i / (p * Cp * (Tznx - Tk(i))) * 1000; % σε λίτρα
    end
end

% Συνολική υπερπαραγωγή όγκου νερού
total_excess_water = sum(excess_water_volume);

fprintf('\nΥπερπαραγωγή όγκου νερού ανά μήνα:\n');
for i = 1:12
    if excess_water_volume(i) > 0
        fprintf('Μήνας %d: %.2f λίτρα (Tk = %.1f°C)\n', i, excess_water_volume(i), Tk(i));
    end
end

fprintf('\nΣυνολική υπερπαραγωγή όγκου ζεστού νερού: %.2f λίτρα\n', total_excess_water);
months_with_excess = find(f_new > 1);

fprintf('\nΜήνες με υπερπαραγωγή (f > 1):\n');
for i = 1:length(months_with_excess)
    month_idx = months_with_excess(i);
    fprintf('Μήνας %d: f = %.4f\n', month_idx, f_new(month_idx));
end

% Βήμα 2: Υπολογισμός συνολικής υπερπαραγωγής ζεστού νερού
excess_energy_total = zeros(1, 12);
for i = 1:12
    if f_new(i) > 1
        excess_energy_total(i) = (f_new(i) - 1) * L(i);
    end
end

% Συνολική υπερπαραγωγή
total_excess = sum(excess_energy_total);

fprintf('\nΣυνολική υπερπαραγωγή ζεστού νερού: %.2f kWh\n', total_excess);
fprintf('Ενεργειακές ανάγκες Ιανουαρίου: %.2f kWh\n', L(1));
fprintf('Ποσοστό κάλυψης Ιανουαρίου από υπερπαραγωγή: %.2f%%\n', (total_excess/L(1))*100);


%%%%%%% Βήμα 2: Υπολογισμός όγκου νερού που περισσεύει μετά την κάλυψη των αναγκών του Δεκεμβρίου 
% και υπολογισμός του ποσού του διοξειδίου του άνθρακα που θα εξοικονομήσουμε 






% Από εδώ και κάτω πρέπει να ελεγχθούν

% Υπολογισμός αρχικών αναγκών Ιανουαρίου (χωρίς ηλιακή παραγωγή)
Q_solar_january = f_new(1) * L(1);  % Ενέργεια από ηλιακά τον Ιανουάριο
L_january_without_solar = L(1) - Q_solar_january;  % Αρχικές ανάγκες μείον ηλιακή παραγωγή

remaining_excess_energy = total_excess - L_january_without_solar;

% Έλεγχος αν η υπερπαραγωγή καλύπτει τις αρχικές ανάγκες του Ιανουαρίου (πλην ηλιακών)
if total_excess >= L_january_without_solar
    fprintf('\nΗ υπερπαραγωγή καλύπτει πλήρως τις ανάγκες του Ιανουαρίου (πλην ηλιακής παραγωγής του μήνα).\n');
    fprintf('Συνολικές ανάγκες Ιανουαρίου: %.2f kWh\n', L(1));
    fprintf('Ηλιακή παραγωγή Ιανουαρίου: %.2f kWh\n', Q_solar_january);
    fprintf('Ανάγκες προς κάλυψη από υπερπαραγωγή: %.2f kWh\n', L_january_without_solar);
    fprintf('Περίσσεια ενέργειας μετά την κάλυψη Ιανουαρίου: %.2f kWh\n', remaining_excess_energy);
    
    % Υπολογισμός εξοικονόμησης CO2 από την κάλυψη Ιανουαρίου
    E_fuel_saved = L_january_without_solar / h_boiler;
    CO2_saved_january = EF_CO2 * E_fuel_saved;
    fprintf('Εξοικονόμηση CO2 από κάλυψη Ιανουαρίου: %.2f kg CO2\n', CO2_saved_january);
else
    fprintf('\nΗ υπερπαραγωγή ΔΕΝ καλύπτει πλήρως τις ανάγκες του Ιανουαρίου.\n');
    fprintf('Συνολικές ανάγκες Ιανουαρίου: %.2f kWh\n', L(1));
    fprintf('Ηλιακή παραγωγή Ιανουαρίου: %.2f kWh\n', Q_solar_january);
    fprintf('Ανάγκες προς κάλυψη από υπερπαραγωγή: %.2f kWh\n', L_january_without_solar);
    fprintf('Διαθέσιμη υπερπαραγωγή: %.2f kWh\n', total_excess);
    fprintf('Έλλειμμα που πρέπει να καλυφθεί από συμβατικές πηγές: %.2f kWh\n', L_january_without_solar - total_excess);
    
    % Υπολογισμός εξοικονόμησης CO2 από τη διαθέσιμη υπερπαραγωγή
    E_fuel_saved = total_excess / h_boiler;
    CO2_saved_january = EF_CO2 * E_fuel_saved;
    fprintf('Εξοικονόμηση CO2 από διαθέσιμη υπερπαραγωγή: %.2f kg CO2\n', CO2_saved_january);
    
    remaining_excess_energy = 0;
end



$$$ απο εδώ και κάτω το πείραμα έχει αποτύχει μπορώ να το δω πιο μετά αν θέλω


% Υπολογισμός όγκου νερού που παρέχεται από ηλιακά κάθε μήνα
water_volume_from_solar = zeros(1, 12);
for i = 1:12
    % Ενέργεια από ηλιακά για τον μήνα i
    energy_from_solar = min(f_new(i), 1) * L(i);
    
    % Μετατροπή ενέργειας σε όγκο νερού
    % Q = V * p * Cp * ΔT => V = Q / (p * Cp * ΔT)
    water_volume_from_solar(i) = energy_from_solar / (p * Cp * (Tznx - Tk(i))) * 1000; % σε λίτρα
end

% Υπολογισμός όγκου νερού από διεποχιακή αποθήκευση για Ιανουάριο
water_from_storage_january = 0;
if remaining_excess_energy > 0
    water_from_storage_january = remaining_excess_energy / (p * Cp * (Tznx - Tk(1))) * 1000; % σε λίτρα
elseif total_excess > 0
    water_from_storage_january = total_excess / (p * Cp * (Tznx - Tk(1))) * 1000; % σε λίτρα
end

% Δημιουργία γραφήματος
figure;
bar(1:12, water_volume_from_solar, 'FaceColor', [0.2 0.6 0.8]);
hold on;

% Προσθήκη δεύτερης μπάρας για Ιανουάριο (διεποχιακή αποθήκευση)
bar(1, water_from_storage_january, 'FaceColor', [0.9 0.4 0.2], 'BarWidth', 0.5);

hold off;

% Προσθήκη ετικετών και τίτλου
xlabel('Μήνας');
ylabel('Όγκος Νερού (λίτρα)');
title('Όγκος Νερού από Ηλιακά και Διεποχιακή Αποθήκευση ανά Μήνα');
legend('Όγκος από Ηλιακά', 'Όγκος από Διεποχιακή Αποθήκευση (Ιανουάριος)', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});