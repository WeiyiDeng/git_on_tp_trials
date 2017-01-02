y_brand_choices = reshape(Y,2,[])';
market_share = sum(y_brand_choices)

brand_prices = reshape(X_price,2,[])';
avg_prices = mean(brand_prices)

brand_feature_display = reshape(X_feature_display,2,[])';
avg_feature_display = sum(brand_feature_display)

% patternsearch helps when derivative-based numerical optimazation methods
% are not efficient at finding the optimal