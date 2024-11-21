function simpleImageCompressorGUIcolor
    % Crea la finestra
    fig = uifigure('Name', 'Image Compressor', 'Position', [100 100 800 500]);
    
    % Inizializza le variabili
    originalImage = [];
    compressedImage = [];
    
    % Carica l'immagine
    loadButton = uibutton(fig, 'Position', [20 350 100 30], 'Text', 'Load Image', ...
                          'ButtonPushedFcn', @(btn, event) loadImage());
                      
    % Slider per selezionare il livello di compressione
    compressionSlider = uislider(fig, 'Position', [150 335 200 3], 'Limits', [0 64], 'Value', 32);
    compressionSliderLabel = uilabel(fig, 'Position', [150 345 200 30], 'Text', 'Number of Coefficient to be kept');

    % Bottone per applicare la compressione
    compressButton = uibutton(fig, 'Position', [20 300 100 30], 'Text', 'Apply', ...
                              'ButtonPushedFcn', @(btn, event) compressImage());

    % Area di visualizzazione dell'immagine originale
    originalImageAxes = uiaxes(fig, 'Position', [400 250 300 200]);
    title(originalImageAxes, 'Original Image');

    fig.Color = [0.9, 0.9, 0.9];
    originalImageAxes.Color = [0.95, 0.95, 0.95];  % Sfondo grigio chiaro

    % Area di visualizzazione dell'immagine compressa
    compressedImageAxes = uiaxes(fig, 'Position', [400 20 300 200]);
    title(compressedImageAxes, 'Compressed Image');
    compressedImageAxes.Color = [0.95, 0.95, 0.95];
    
    loadButton.FontSize = 14;
    loadButton.FontWeight = 'bold';
    loadButton.BackgroundColor = [0.1, 0.4, 0.8];  % Azzurro
    loadButton.FontColor = [1, 1, 1];
    
    compressButton.FontSize = 14;
    compressButton.FontWeight = 'bold';
    compressButton.BackgroundColor = [0.2, 0.7, 0.2];  % Verde
    compressButton.FontColor = [1, 1, 1];
    
    loadButton.Tooltip = 'Select image to be loaded';
    compressButton.Tooltip = 'Apply the selected compression';
    compressionSlider.Tooltip = 'Select the number of coefficients to be kept in the blocks';

    % mseLabel = uilabel(fig, 'Position', [150 250 200 30], 'Text', 'MSE:');
    % crLabel = uilabel(fig, 'Position', [150 220 200 30], 'Text', 'Compression Ratio:');

    msePanel = uipanel(fig, 'Position', [145 245 300 40], 'BackgroundColor', [0.8 0.8 0.8]);
    msePanel.BorderType = 'line'; 
    msePanel.BorderWidth = 1;
    msePanel.BorderColor = [0.2 0.2 0.2];
    
    mseLabel = uilabel(msePanel, 'Position', [5 5 290 30], 'Text', 'MSE:');
    mseLabel.BackgroundColor = [1 1 1];
    mseLabel.FontSize = 14;
    mseLabel.FontWeight = 'bold';
    mseLabel.HorizontalAlignment = 'center';
    mseLabel.FontColor = [0 0.4 0.8];
    
    psnrPanel = uipanel(fig, 'Position', [145 215 300 40], 'BackgroundColor', [0.8 0.8 0.8]);
    psnrPanel.BorderType = 'line';
    psnrPanel.BorderWidth = 1;
    psnrPanel.BorderColor = [0.2 0.2 0.2];
    
    psnrLabel = uilabel(psnrPanel, 'Position', [5 5 290 30], 'Text', 'PSNR:');
    psnrLabel.BackgroundColor = [1 1 1];
    psnrLabel.FontSize = 14;
    psnrLabel.FontWeight = 'bold';
    psnrLabel.HorizontalAlignment = 'center';
    psnrLabel.FontColor = [0 0.4 0.8];

    % Pannello per Compression Ratio
    crPanel = uipanel(fig, 'Position', [145 185 300 40], 'BackgroundColor', [0.8 0.8 0.8]);
    crPanel.BorderType = 'line';
    crPanel.BorderWidth = 1;
    crPanel.BorderColor = [0.2 0.2 0.2];
    
    crLabel = uilabel(crPanel, 'Position', [5 5 290 30], 'Text', 'Compression Ratio:');
    crLabel.BackgroundColor = [1 1 1];
    crLabel.FontSize = 14;
    crLabel.FontWeight = 'bold';
    crLabel.HorizontalAlignment = 'center';
    crLabel.FontColor = [0 0.4 0.8];

    % Funzione per caricare l'immagine
    function loadImage()
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Immagini (*.jpg, *.png, *.bmp, *.heic)'});
        if isequal(file, 0)
            return;
        end
        imgPath = fullfile(path, file);
        originalImage = im2double((imread(imgPath)));
        imshow(originalImage, 'Parent', originalImageAxes);
    end

    % Funzione per applicare la compressione
    function compressImage()
        if isempty(originalImage)
            uialert(fig, 'Carica prima un''immagine!', 'Errore');
            return;
        end
        
        % Ottieni il livello di compressione dallo slider
        compressionLevel = compressionSlider.Value;
        
        [rows, cols, ~] = size(originalImage);
        rows = floor(rows / 8) * 8;
        cols = floor(cols / 8) * 8;
        rows
        cols
        I = originalImage(1:rows, 1:cols, :);
        I = im2double(I);
        R = I(:,:,1);
        G = I(:,:,2);
        B = I(:,:,3);
        T = dctmtx(8);
        dct = @(block_struct) T * block_struct.data * T';
        Rb = blockproc(R,[8 8],dct);
        Gb = blockproc(G,[8 8],dct);
        Bb = blockproc(B,[8 8],dct);
        
        % Crea una maschera dinamica in base al livello di compressione
        mask = createMask(compressionLevel);
        
        Rb2 = blockproc(Rb,[8 8],@(block_struct) mask .* block_struct.data);
        Gb2 = blockproc(Gb,[8 8],@(block_struct) mask .* block_struct.data);
        Bb2 = blockproc(Bb,[8 8],@(block_struct) mask .* block_struct.data);
        invdct = @(block_struct) T' * block_struct.data * T;
        IR = blockproc(Rb2,[8 8],invdct);
        IG = blockproc(Gb2,[8 8],invdct);
        IB = blockproc(Bb2,[8 8],invdct);
        compressedImage = cat(3,IR,IG,IB);
        
        mse_R = mean((R(:) - IR(:)).^2);
        mse_G = mean((G(:) - IG(:)).^2);
        mse_B = mean((B(:) - IB(:)).^2);
        MSE = (mse_R+mse_B+mse_G)/3;

        total_coeffs = numel(mask) * (rows / 8) * (cols / 8); 
        kept_coeffs = sum(mask(:) ~= 0) * (rows / 8) * (cols / 8); 
        compression_ratio = kept_coeffs / total_coeffs * 100;
        format long
        psnr_total = 10 * log10(1 / MSE);
        mseLabel.Text = sprintf('MSE: %.8f ', MSE);
        psnrLabel.Text = sprintf('PSNR: %.4f dB%',psnr_total);
        if psnr_total < 30
            psnrLabel.FontColor = [1, 0, 0];  % Rosso
        else
            psnrLabel.FontColor = [0, 1, 0]; % Verde
        end
        crLabel.Text = sprintf('Compression Ratio: %.4f%%', compression_ratio);

        % Mostra l'immagine compressa
        imshow(compressedImage, 'Parent', compressedImageAxes);
        imwrite(compressedImage, 'boh.jpg');
    end

    % Funzione per creare una maschera di compressione
    function mask = createMask(level)
        % Crea una maschera 8x8 con valori in base al livello di compressione
        threshold = round(level);  % Imposta la soglia in base al livello
        mask = ones(8);
        for i = 1:8
            for j = 1:8
                if i + j > threshold
                    mask(i, j) = 0;
                end
            end
        end
    end
end
