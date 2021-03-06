exponentialObservationsGenerator <- function(number_of_batches_to_construct_with = 1000)
{
    lambda <- 0.2;
    observations_per_batch <- 40;
    number_of_batches_to_observe <- number_of_batches_to_construct_with;
    averages_of_batches <- NULL;
    sample_mean <- NULL;
    sample_standard_deviation <- NULL;
    matrix_of_observation_batches <- NULL;
    absolute_filepath_to_export_to <- '/home/parallels/R/coursera/statistical_inference/course_project/';

    setNumberOfBatchesToObserve <- function(number_of_batches_to_set)
    {
        number_of_batches_to_observe <<- number_of_batches_to_set;
    }
    
    initializeBatchData <- function()
    {
        sample_mean <<- NULL;
        sample_standard_deviation <<- NULL;
        matrix_of_observation_batches <<- NULL;
        averages_of_batches <<- NULL;
    }
    
    getNumberOfObservationsPerBatch <- function()
    {
        observations_per_batch;
    }
    
    getNumberOfBatchesToObserve <- function()
    {
        number_of_batches_to_observe;
    }
    
    generateBatchesOfObservations <- function()
    {
        initializeBatchData();
        total_number_of_observations <- number_of_batches_to_observe * observations_per_batch;
        vector_of_all_observations <- rexp(total_number_of_observations, lambda);
        # We will make each row of the matrix be a batch of observations
        matrix_of_observation_batches <<- matrix(data = vector_of_all_observations, nrow = number_of_batches_to_observe,
                                                 ncol = observations_per_batch, byrow = TRUE);
        # Compute the averages of the batches
        averages_of_batches <<- apply(matrix_of_observation_batches, 1, mean);

        computeSampleMean();
        computeSampleStandardDeviation();

        invisible(matrix_of_observation_batches);
    }
    # Output the theoretical sample average mean/variance and the experimental sample average mean/variance
    produceStatisticsReport <- function()
    {
        statistics_report_file <- getAbsoluteFilePathForFile('statistics_report.log');
        
        observations_per_batch <- getNumberOfObservationsPerBatch();
        number_of_batches_to_observe <- getNumberOfBatchesToObserve();
        
        lines_to_write <- c(
            paste0(as.integer(number_of_batches_to_observe), " samples of the average of ", observations_per_batch ," exponentials with lambda=", lambda, " were taken:", collapse=""),
            '',
            # Compare Mean of Averages with Theoretical Value
            paste0('Population Average: ', getTheoreticalPopulationMean()),
            paste0('Theoretical Mean of Averages of ', observations_per_batch ,' exponentials: ', getTheoreticalSampleMean(), collapse=""),
            paste0('Experimental Mean of Averages of ', observations_per_batch ,' exponentials: ', getSampleMean(), collapse=""),
            '',
            # Compare Variance of Averages with Theoretical Value
            paste0('Theoretical Variance of Averages of ', observations_per_batch ,' exponentials: ', getTheoreticalSampleVariance(), collapse=""),
            paste0('Experimental Sample Variance of Averages of ', observations_per_batch ,' exponentials: ', getSampleVariance(), collapse=""),
            '',
            # Compare Standard Deviation of Averages with Theoretical Value
            paste0('Theoretical Standard Devation of Averages of ', observations_per_batch ,' exponentials: ', getTheoreticalSampleStandardDeviation(), collapse=""),
            paste0('Experimental Standard Devation of Averages of ', observations_per_batch ,' exponentials: ', getSampleStandardDeviation(), collapse="")
            
        );
        
        writeLines(lines_to_write, statistics_report_file);
    }
    # Show a histogram of the experimental sample averages with the theoretical normal distribution the sample averages
    #   should be distributed by overlayed as a curve
    produceSampleDensityHistogramAgainstNormalCurve <- function()
    {
        density_comparison_histogram_filepath <- getAbsoluteFilePathForFile('sample_density_comparison_histogram.jpg');
        jpeg(density_comparison_histogram_filepath);
        # Produce the histogram representing the sample data.
        x_axis_label <- paste0("Averages of ", observations_per_batch ," Exponentials", collapse="");
        main_label <- paste0("Sample Average Distribution Compared To\nNormal Distribution for ", as.integer(number_of_batches_to_observe), " Sample Averages");
        # Display the samples as DENSITIES, NOT AS FREQUENCIES to allow for comparison to the normal density curve
        hist(x=averages_of_batches, breaks=100, xlab=x_axis_label, freq=FALSE, main=main_label, ylab="Distribution Density");
        # Produce the points which will comprise the expected normal distributon curve
        # Get a vector of probability steps, with one step for every sample average
        probability_steps_for_quantile_calculation <- seq((1/number_of_batches_to_observe), 1, (1/number_of_batches_to_observe));
        theoretical_sample_mean <- getTheoreticalSampleMean();
        theoretical_sample_standard_deviation <- getTheoreticalSampleStandardDeviation();
        # Compute the theoretical quantile for every sample average
        normal_quantiles <- qnorm(probability_steps_for_quantile_calculation, mean=theoretical_sample_mean, sd=theoretical_sample_standard_deviation);
        # Compute the theoretical density at every theoretical quanitle
        normal_densities <- dnorm(normal_quantiles, mean=theoretical_sample_mean, sd=theoretical_sample_standard_deviation);
        # Plot the theoretical sample average density distribution, which is approximated as a normal distribution curve
        points(x=normal_quantiles, y=normal_densities, type="l");
        dev.off();
        invisible(density_comparison_histogram_filepath);
    }

    getAveragesOfBatches <- function()
    {
        averages_of_batches;
    }
    
    # The sample mean is the mean of the batch averages
    computeSampleMean <- function()
    {
        sample_mean <<- mean(averages_of_batches);
        sample_mean;
    }
    
    getSampleMean <- function()
    {
        sample_mean;
    }
    
    computeSampleStandardDeviation <- function()
    {
        sample_standard_deviation <<- sd(averages_of_batches);
        sample_standard_deviation;
    }
    getSampleStandardDeviation <- function()
    {
        sample_standard_deviation;
    }
    # Var(sample_mean) = standard_deviation(sample_mean)^2
    getSampleVariance <- function()
    {
        sample_variance <- (sample_standard_deviation^2);
        sample_variance;
    }
    
    getTheoreticalSampleMean <- function()
    {
        getTheoreticalPopulationMean();
    }
    # Var(sample_mean) = Var(X) / n
    getTheoreticalSampleVariance <- function()
    {
        theoretical_variance_of_population <- getTheoreticalPopulationVariance();
        theoretical_variance_of_sample_mean <- theoretical_variance_of_population / observations_per_batch;
        theoretical_variance_of_sample_mean;
    }
    # standard_deviation(sample_mean) = sqrt(Var(sample_mean))
    getTheoreticalSampleStandardDeviation <- function()
    {
        theoretical_variance_of_sample_mean <- getTheoreticalSampleVariance();
        theoretical_standard_deviation_of_sample_mean = sqrt(theoretical_variance_of_sample_mean);
        theoretical_standard_deviation_of_sample_mean;
    }
    
    # For exponential distribution, E[X] = 1 / lambda = mu
    getTheoreticalPopulationMean <- function()
    {
        theoretical_mean <- (1.0 / lambda);
        theoretical_mean
    }
    # For exponential distribution, Var(X) = 1 / lambda^2
    getTheoreticalPopulationVariance <- function()
    {
        theoretical_variance <- (1.0 / (lambda^2));
        theoretical_variance;
    }
    # For exponential distribution, sd(X) = 1 / lambda
    getTheoreticalPopulationStandardDeviation <- function()
    {
        theoretical_standard_deviation <- (1.0 / lambda);
        theoretical_standard_deviation
    }
    # Functions for outputting the data and the density comparison histogram
    getAbsoluteFilePathForFile <- function(file_name)
    {
        absolute_file_path <- paste0(absolute_filepath_to_export_to, as.integer(number_of_batches_to_observe), "_samples_", file_name, collapse = '');
        absolute_file_path;
    }
    # Only return the functions which are needed to generate the histograms and reports
    list(generateBatchesOfObservations = generateBatchesOfObservations,
         produceStatisticsReport = produceStatisticsReport,
         produceSampleDensityHistogramAgainstNormalCurve = produceSampleDensityHistogramAgainstNormalCurve
     );
}

executeExponentialGeneration <- function(number_of_batches_to_construct_with = 1000)
{
    # Generate the averages of exponentials
    exponentialObservationsGeneratorInstance <- exponentialObservationsGenerator(number_of_batches_to_construct_with);
    exponentialObservationsGeneratorInstance$generateBatchesOfObservations();
    # Product Reports and Plots regarding the data
    exponentialObservationsGeneratorInstance$produceStatisticsReport();
    exponentialObservationsGeneratorInstance$produceSampleDensityHistogramAgainstNormalCurve();

    invisible(exponentialObservationsGeneratorInstance);
}