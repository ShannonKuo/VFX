hdr = hdrread( '../result.hdr' );
tonemap_p( hdr);

function rgb = tonemap_p( hdr )
    a = 0.6;
    phi = 8;
    epsilon = 0.05;
    lum_w = 0.27 * hdr(:,:,1) + 0.67 * hdr(:,:,2) + 0.06 * hdr(:,:,3);
    image_size = size( hdr );
    height = image_size(1);
    width = image_size(2);
    N = height * width;
    sum_all = 0;
   
    for i = 1: height
        for j = 1: width
            sum_all = sum_all + log( 0.00000001+ lum_w(i, j) );
        end
    end
    %lum_white = max( lum_w(:) );
    lum_white = 1e20;
    lum_w_bar = double( exp (sum_all / N) );
    
    lum = a / lum_w_bar * lum_w;
    for i = 1: height
        for j = 1: width
            lum_d(i, j) = lum(i, j) * ( 1 + lum(i, j) / lum_white / lum_white ) / (1 + lum(i, j) );
        end
    end
    
    hsv = rgb2hsv( hdr );
    hsv(:,:,3) = lum_d;
    rgb = hsv2rgb( hsv);
    imshow(rgb)
    imwrite(rgb, '../tonemapping1.png')
    for i = 1: height
        for j = 1: width
            for k = 1: 8
                s = 1 * 1.6 ^ k;
                alpha1 = 0.35;
                R1(i, j, k) = exp( -( i ^ 2 + j ^ 2) / ( alpha1 ) ^ 2 ) / ( pi * ( alpha1 * s ) ^ 2 );
                alpha2 = 0.35 * 1.6;
                R2(i, j, k) = exp( -( i ^ 2 + j ^ 2) / ( alpha2 ) ^ 2 ) / ( pi * ( alpha2 * s ) ^ 2 );
            end
        end
    end
    
    for k = 1: 8
        V1(:,:,k) = conv2( lum_w, R1(:,:,k));
        V2(:,:,k) = conv2( lum_w, R2(:,:,k));
    end
    for i = 1: height
        for j = 1: width
            for k = 1:8
                V(i, j, k) = ( V1(i, j, k) - V2(i, j, k)) / (2 ^ phi * a / (k ^ 2) + V1(i, j, k));
            end
        end
    end
    disp(size(V));
    for i = 1: height
        for j = 1: width
            for k = 1:8
                if abs(V(i, j, k)) < epsilon
                    V1_new(i, j) = V(i, j, k);
                end
            end
        end
    end
    for i = 1: height
        for j = 1: width
            lum_d2(i, j) = lum_w(i, j) / (1 + V1_new(i, j));
        end
    end
    hvs = rgb2hsv( hdr );
    hvs(:,:,3) = lum_d2;
    rgb = hsv2rgb( hsv);
    imshow(rgb)
    imwrite(rgb, '../tonemapping2.png')
end