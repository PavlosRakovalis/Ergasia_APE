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

    % Υπολογισμός όγκου νερού με τον ίδιο τρόπο όπως στο Ερώτημα 5
    temp_total_water = zeros(1, 12);
    temp_required_water = zeros(1, 12);
    excess_water = zeros(1, 12);
    
    for i = 1:12
        % Υπολογισμός συνολικής παραγωγής ενέργειας για τον μήνα i
        total_energy_i = f_new(i) * L(i);
        
        % Μετατροπή παραγωγής ενέργειας σε όγκο νερού
        temp_total_water(i) = total_energy_i / (p * Cp * (Tznx - Tk(i))) * 1000; % σε λίτρα
        
        % Υπολογισμός απαιτούμενου όγκου νερού
        temp_required_water(i) = N(i) * HKznx; % λίτρα
        
        % Υπολογισμός υπερπαραγωγής όγκου νερού
        excess_water(i) = max(0, temp_total_water(i) - temp_required_water(i));
    end
    
    % Συνολική περίσσεια όγκου νερού από όλους τους μήνες
    total_excess_water_volume = sum(excess_water);
    
    % Απαιτούμενος όγκος νερού για τον Δεκέμβριο
    Vdecember_required = N(12) * HKznx; % λίτρα
    
    % Έλεγχος αν η περίσσεια νερού καλύπτει τις ανάγκες του Δεκεμβρίου
    if total_excess_water_volume >= Vdecember_required
        Ac_new_found = Ac_new;
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
%      θα χρησιμοποιηθούν για την κάλυψη των αναγκών των υπόλοιπων μηνών.
%
%   2) Το 1 συνεπάγεται ότι θα αλλάξει και ο όγκος της δεξαμενής 
%      διεποχιακής αποθήκευσης
%
% ============================================================================

% Βήμα 1: Υπολογισμός συνολικού υπερπαραγόμενου ζεστού νερού και συνεπώς και νέου όγκου διεποχιακής αποθήκευσης.

% Βήμα 1: Εντοπισμός μηνών με f > 1 και υπολογισμός υπερπαραγωγής νερού
excess_water_volume = zeros(1, 12);
total_created_water_volume_by_sollars = zeros(1, 12);
required_water_volume = zeros(1, 12);

for i = 1:12
    % Υπολογισμός συνολικής παραγωγής ενέργειας για τον μήνα i
    total_energy_i = f_new(i) * L(i);
    
    % Μετατροπή παραγωγής ενέργειας σε όγκο νερού
    % Q = V * p * Cp * ΔT => V = Q / (p * Cp * ΔT)
    total_created_water_volume_by_sollars(i) = total_energy_i / (p * Cp * (Tznx - Tk(i))) * 1000; % σε λίτρα
    
    % Υπολογισμός απαιτούμενου όγκου νερού
    required_water_volume(i) = N(i) * HKznx; % λίτρα
    
    % Υπολογισμός υπερπαραγωγής όγκου νερού
    excess_water_volume(i) = max(0, total_created_water_volume_by_sollars(i) - required_water_volume(i));
end

total_created_water_volume_by_sollars(12) = 0; % Ο Δεκέμβριος δεν παράγει ζεστό νερό από ηλιακά

% Συνολική υπερπαραγωγή όγκου νερού
total_excess_water = sum(excess_water_volume);
fprintf('\nΣυνολική υπερπαραγωγή όγκου ζεστού νερού: %.2f λίτρα\n', total_excess_water);





%%%%%%%%%%%%% Διάγραμμα λιτρων %%%%%%%%%%%%%%%%

% Προετοιμασία δεδομένων για stacked bar chart
normal_volume = min(total_created_water_volume_by_sollars, required_water_volume);
excess_volume = max(total_created_water_volume_by_sollars - required_water_volume, 0);

% Δημιουργία γραφήματος με stacked bars
figure;
b = bar(1:12, [normal_volume; excess_volume]', 'stacked');
b(1).FaceColor = [0.2 0.6 0.8]; % Μπλε για κανονική παραγωγή
b(2).FaceColor = [0.2 0.8 0.4]; % Πράσινο για υπερπαραγωγή
hold on;

% Προσθήκη οριζόντιων διακεκομμένων γραμμών για την απαιτούμενη ποσότητα νερού κάθε μήνα
for i = 1:12
    plot([i-0.4, i+0.4], [required_water_volume(i), required_water_volume(i)], 'r--', 'LineWidth', 1.5);
end

hold off;

% Προσθήκη ετικετών και τίτλου
xlabel('Μήνας');
ylabel('Όγκος Νερού (λίτρα)');
title('Όγκος Νερού από Ηλιακά και Διεποχιακή Αποθήκευση ανά Μήνα');
legend('Όγκος ΖΝΧ από Ηλιακά', 'Υπερπαραγωγή όγκου ΖΝΧ από Ηλιακά', 'Απαιτούμενος όγκος νερού', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});



% Υπολογισμός ελλείμματος νερού για κάθε μήνα
deficit_water_volume = zeros(1, 12);
for i = 1:12
    deficit_water_volume(i) = max(0, required_water_volume(i) - total_created_water_volume_by_sollars(i));
end

% Υπολογισμός νερού που χρησιμοποιείται από διεποχιακή δεξαμενή ανά μήνα
water_used_from_seasonal_tank_per_month = zeros(1, 12);
remaining_seasonal_water = total_excess_water;

% Ξεκινάμε από τον Δεκέμβριο (μήνας 12)
if deficit_water_volume(12) > 0 && remaining_seasonal_water > 0
    water_used_from_seasonal_tank_per_month(12) = min(deficit_water_volume(12), remaining_seasonal_water);
    remaining_seasonal_water = remaining_seasonal_water - water_used_from_seasonal_tank_per_month(12);
end

% Συνεχίζουμε από τον Ιούνιο μέχρι τον Νοέμβριο (6:11)
for i = 6:11
    if remaining_seasonal_water <= 0
        break;
    end
    
    if deficit_water_volume(i) > 0
        water_used_from_seasonal_tank_per_month(i) = min(deficit_water_volume(i), remaining_seasonal_water);
        remaining_seasonal_water = remaining_seasonal_water - water_used_from_seasonal_tank_per_month(i);
    end
end

% Τέλος από τον Ιανουάριο μέχρι τον Μάιο (1:5)
for i = 1:5
    if remaining_seasonal_water <= 0
        break;
    end
    
    if deficit_water_volume(i) > 0
        water_used_from_seasonal_tank_per_month(i) = min(deficit_water_volume(i), remaining_seasonal_water);
        remaining_seasonal_water = remaining_seasonal_water - water_used_from_seasonal_tank_per_month(i);
    end
end


fprintf('\n=== Έλεγχος Διεποχιακής Αποθήκευσης ===\n');
fprintf('Συνολική υπερπαραγωγή (total_excess_water): %.2f λίτρα\n', total_excess_water);
fprintf('Άθροισμα χρησιμοποιούμενου νερού: %.2f λίτρα\n', sum(water_used_from_seasonal_tank_per_month));
fprintf('Υπόλοιπο νερό στη δεξαμενή: %.2f λίτρα\n', remaining_seasonal_water);

if sum(water_used_from_seasonal_tank_per_month) > total_excess_water
    fprintf('⚠️ ΠΡΟΒΛΗΜΑ: Χρησιμοποιήθηκε περισσότερο νερό από το διαθέσιμο!\n');
else
    fprintf('✓ OK: Το χρησιμοποιούμενο νερό είναι μικρότερο ή ίσο με το διαθέσιμο\n');
end
fprintf('=====================================\n\n');


%%%%%%%%%%%%% Διάγραμμα λιτρων %%%%%%%%%%%%%%%%

% Προετοιμασία δεδομένων για stacked bar chart
normal_volume = min(total_created_water_volume_by_sollars, required_water_volume);
excess_volume = max(total_created_water_volume_by_sollars - required_water_volume, 0);

% Δημιουργία γραφήματος με stacked bars (3 στοίβες)
figure;
b = bar(1:12, [normal_volume; excess_volume; water_used_from_seasonal_tank_per_month]', 'stacked');
b(1).FaceColor = [0.2 0.6 0.8]; % Μπλε για κανονική παραγωγή από ηλιακά
b(2).FaceColor = [0.2 0.8 0.4]; % Πράσινο για υπερπαραγωγή από ηλιακά
b(3).FaceColor = [1.0 0.6 0.0]; % Πορτοκαλί για νερό από διεποχιακή δεξαμενή
hold on;

% Προσθήκη οριζόντιων διακεκομμένων γραμμών για την απαιτούμενη ποσότητα νερού κάθε μήνα
for i = 1:12
    plot([i-0.4, i+0.4], [required_water_volume(i), required_water_volume(i)], 'r--', 'LineWidth', 1.5);
end

hold off;

% Προσθήκη ετικετών και τίτλου
xlabel('Μήνας');
ylabel('Όγκος Νερού (λίτρα)');
title('Όγκος Νερού από Ηλιακά και Διεποχιακή Αποθήκευση ανά Μήνα');
legend('Όγκος ΖΝΧ από Ηλιακά', 'Υπερπαραγωγή όγκου ΖΝΧ από Ηλιακά', 'ΖΝΧ από Διεποχιακή Δεξαμενή', 'Απαιτούμενος όγκος νερού', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});














%%%%%%%%%%%%%%%%%%%%%%%%%%%% Υπολογισμός νέου Ac για καλυψη για όλο τον χρόνο απο την δεξαμενη%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n=== ΠΡΙΝ ΤΟ ΕΡΩΤΗΜΑ 5 ===\n');
fprintf('Επιφάνεια Συλλεκτών: %.2f m²\n', Ac_new_found);
fprintf('Μέγεθος Δεξαμενής Διεποχιακής Αποθήκευσης: %.2f λίτρα\n', Vtank);
fprintf('========================\n\n');





% Αρχικοποίηση αναζήτησης
Ac_new_max = 1e6;

Ac_new_found = NaN;

for Ac_new = 0:0.25:Ac_new_max
   
     X_new = (Ac_new./L).*FR_mult_Ul.*FRdot_div_FR.*(Tanaf - Ta).*dt.*k1.*k2;

     Y_new = (Ac_new./L).*FR_mult_tan.*FRdot_div_FR.*ta_div_tan.*Hb.*k3;

     f_new = 1.029*Y_new - 0.065*X_new - 0.245.*(Y_new.^2) + 0.0018.*(X_new.^2) + 0.0215.*(Y_new.^3);
     
     % Υπολογισμός υπερπαραγωγής και ελλείμματος όγκου νερού για κάθε μήνα
     temp_excess_water_volume = zeros(1, 12);
     temp_deficit_water_volume = zeros(1, 12);
     temp_total_created_water = zeros(1, 12);
     temp_required_water = zeros(1, 12);
     
     for i = 1:12
         % Υπολογισμός συνολικής παραγωγής ενέργειας για τον μήνα i
         total_energy_i = f_new(i) * L(i);
         
         % Μετατροπή παραγωγής ενέργειας σε όγκο νερού
         temp_total_created_water(i) = total_energy_i / (p * Cp * (Tznx - Tk(i))) * 1000; % σε λίτρα
         
         % Υπολογισμός απαιτούμενου όγκου νερού
         temp_required_water(i) = N(i) * HKznx; % λίτρα
         
         % Υπολογισμός υπερπαραγωγής και ελλείμματος
         temp_excess_water_volume(i) = max(0, temp_total_created_water(i) - temp_required_water(i));
         temp_deficit_water_volume(i) = max(0, temp_required_water(i) - temp_total_created_water(i));
     end
     
     temp_total_created_water(12) = 0; % Ο Δεκέμβριος δεν παράγει ζεστό νερό από ηλιακά
     temp_excess_water_volume(12) = 0;
     temp_deficit_water_volume(12) = temp_required_water(12);
     
     % Συνολική υπερπαραγωγή όγκου νερού (διαθέσιμο για διεποχιακή αποθήκευση)
     total_excess_water_volume = sum(temp_excess_water_volume);
     
     % Συνολικό έλλειμμα όγκου νερού (απαιτούμενο από διεποχιακή αποθήκευση)
     total_deficit_water_volume = sum(temp_deficit_water_volume);
     
     % Έλεγχος αν η περίσσεια νερού καλύπτει όλα τα ελλείμματα του χρόνου
     if total_excess_water_volume >= total_deficit_water_volume
         Ac_new_found = Ac_new;
         break
     end
end

% Υπολογισμός του νέου όγκου δεξαμενής διεποχιακής αποθήκευσης
Vtank_new = sum(excess_water_volume);

fprintf('\n=== ΜΕΤΑ ΤΟ ΕΡΩΤΗΜΑ 5 ===\n');
fprintf('Νέα Επιφάνεια Συλλεκτών: %.2f m²\n', Ac_new_found);
fprintf('Νέο Μέγεθος Δεξαμενής Διεποχιακής Αποθήκευσης: %.2f λίτρα\n', Vtank_new);
fprintf('=========================\n\n');

% Υπολογισμός για τα τελικά διαγράμματα με το νέο Ac
X_final = (Ac_new_found./L).*FR_mult_Ul.*FRdot_div_FR.*(Tanaf - Ta).*dt.*k1.*k2;
Y_final = (Ac_new_found./L).*FR_mult_tan.*FRdot_div_FR.*ta_div_tan.*Hb.*k3;
f_final = 1.029*Y_final - 0.065*X_final - 0.245.*(Y_final.^2) + 0.0018.*(X_final.^2) + 0.0215.*(Y_final.^3);

% Υπολογισμός ενέργειας που παράγεται από το ηλιακό σύστημα κάθε μήνα
Q_solar_final = f_final .* L;  % Ενέργεια που παράγει το ηλιακό σύστημα

% Διάγραμμα 1: Ενέργεια ηλιακού συστήματος vs ενεργειακές ανάγκες
figure;
bar(1:12, Q_solar_final);
hold on;
plot(1:12, L, 'r--o', 'LineWidth', 2, 'MarkerSize', 6);
hold off;
xlabel('Μήνας');
ylabel('Ενέργεια (kWh)');
title('Ενέργεια Ηλιακού Συστήματος vs Ενεργειακές Ανάγκες ανά Μήνα (Νέο Ac)');
legend('Ενέργεια Ηλιακού Συστήματος', 'Ενεργειακές Ανάγκες', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});

% Διάγραμμα 2: Παράγοντας f ανά μήνα
figure;
bar(1:12, f_final);
hold on;
yline(1, 'r--', 'LineWidth', 2);
hold off;
xlabel('Μήνας');
ylabel('Παράγοντας f');
title('Παράγοντας f ανά Μήνα (Νέο Ac)');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});
ylim([0 max(f_final)*1.1]);

% Υπολογισμός όγκων νερού για διαγράμματα 3 και 4
final_total_water = zeros(1, 12);
final_required_water = zeros(1, 12);
final_excess_water = zeros(1, 12);
final_deficit_water = zeros(1, 12);

for i = 1:12
    total_energy_i = f_final(i) * L(i);
    final_total_water(i) = total_energy_i / (p * Cp * (Tznx - Tk(i))) * 1000;
    final_required_water(i) = N(i) * HKznx;
    final_excess_water(i) = max(0, final_total_water(i) - final_required_water(i));
    final_deficit_water(i) = max(0, final_required_water(i) - final_total_water(i));
end

% Διάγραμμα 3: Όγκος νερού χωρίς διεποχιακή αποθήκευση
normal_vol = min(final_total_water, final_required_water);
excess_vol = max(final_total_water - final_required_water, 0);

figure;
b = bar(1:12, [normal_vol; excess_vol]', 'stacked');
b(1).FaceColor = [0.2 0.6 0.8];
b(2).FaceColor = [0.2 0.8 0.4];
hold on;
for i = 1:12
    plot([i-0.4, i+0.4], [final_required_water(i), final_required_water(i)], 'r--', 'LineWidth', 1.5);
end
hold off;
xlabel('Μήνας');
ylabel('Όγκος Νερού (λίτρα)');
title('Όγκος Νερού από Ηλιακά ανά Μήνα (Νέο Ac)');
legend('Όγκος ΖΝΧ από Ηλιακά', 'Υπερπαραγωγή όγκου ΖΝΧ', 'Απαιτούμενος όγκος', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});

% Υπολογισμός διανομής από διεποχιακή δεξαμενή
final_seasonal_water = zeros(1, 12);
remaining = sum(final_excess_water);

for i = 1:12
    if remaining <= 0
        break;
    end
    if final_deficit_water(i) > 0
        final_seasonal_water(i) = min(final_deficit_water(i), remaining);
        remaining = remaining - final_seasonal_water(i);
    end
end

% Διάγραμμα 4: Όγκος νερού με διεποχιακή αποθήκευση
figure;
b = bar(1:12, [normal_vol; excess_vol; final_seasonal_water]', 'stacked');
b(1).FaceColor = [0.2 0.6 0.8];
b(2).FaceColor = [0.2 0.8 0.4];
b(3).FaceColor = [1.0 0.6 0.0];
hold on;
for i = 1:12
    plot([i-0.4, i+0.4], [final_required_water(i), final_required_water(i)], 'r--', 'LineWidth', 1.5);
end
hold off;
xlabel('Μήνας');
ylabel('Όγκος Νερού (λίτρα)');
title('Όγκος Νερού με Διεποχιακή Αποθήκευση (Νέο Ac)');
legend('Όγκος ΖΝΧ από Ηλιακά', 'Υπερπαραγωγή', 'ΖΝΧ από Διεποχιακή Δεξαμενή', 'Απαιτούμενος όγκος', 'Location', 'best');
grid on;
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαι', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ'});















