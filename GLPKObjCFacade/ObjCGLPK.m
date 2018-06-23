//
//  ObjCGLPK.m
//  GLPKFramework
//
//  Created by Dirk Fröhling on 22.06.18.
//

#import "ObjCGLPK.h"
#include "glpk.h"

@interface ObjCGLPK ()

@property glp_prob *problemPointer;

@end

@implementation ObjCGLPK

@synthesize problemPointer;
@synthesize direction = _direction;


- (instancetype)initWithName:(NSString *)name andDirection:(GLPKDirection)direction {
    if (self = [super init]) {
        problemPointer = glp_create_prob();
        glp_set_prob_name(problemPointer, [name cStringUsingEncoding:NSASCIIStringEncoding]);
        _direction = direction;
        if (direction == GLPKMaximize) {
            glp_set_obj_dir(problemPointer, GLP_MAX);
        } else {
            glp_set_obj_dir(problemPointer, GLP_MIN);
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithName:@"dummy" andDirection:GLPKMinimize];
}

/**
 *  @return The optimization direction flag (i.e. “sense” of the objective function).
 **/
- (GLPKDirection)direction {
    int dir = glp_get_obj_dir(self.problemPointer);
    _direction = dir == GLP_MAX ? GLPKMaximize : GLPKMinimize;
    return _direction;
}

/** @brief Set the optimization direction flag (i.e. “sense” of the objective function).
 *  @param direction The new direction.
 **/
- (void)setDirection:(GLPKDirection)direction {
    _direction = direction;
    if (_direction == GLPKMaximize) {
        glp_set_obj_dir(self.problemPointer, GLP_MAX);
    } else {
        glp_set_obj_dir(self.problemPointer, GLP_MIN);
    }
}

/** @brief Erases the content of the specified problem object. Object remains valid.
 **/
- (void)reset {
    glp_erase_prob(self.problemPointer);
}

/**
 @brief Adds `amount` rows (constraints) to the problem object.
 New rows are always added to the end of the row list, so the ordinal numbers of existing rows are not changed.
 
 @param amount The number of rows to add.
 
 @note Being added each new row is initially free (unbounded) and has empty list of the constraint coeﬃcients.
 @note Each new row becomes a non-active (non-binding) constraint, i.e. the corresponding auxiliary variable is marked as basic.
 @note If the basis factorization exists, adding row(s) invalidates it.
 
 @return The ordinal number of the ﬁrst new row added to the problem object.
 */
- (NSInteger) addRows:(int32_t)amount {
    return glp_add_rows(self.problemPointer, amount);
}

/**
 @brief Adds `amount` columns (structural variables) to the speciﬁed problem object.
 New columns are always added to the end of the column list, so the ordinal numbers of existing columns are not changed.
 
 @param amount The number of columns to add.
 
 @note Being added each new column is initially ﬁxed at zero and has empty list of the constraint coeﬃcients.
 @note Each new column is marked as non-basic, i.e. zero value of the corresponding structural variable becomes an active (binding) bound.
 @note If the basis factorization exists, it remains valid.
 
 @return The ordinal number of the ﬁrst new column added to the problem object.
 */
- (NSInteger) addCols:(int32_t)amount {
    return glp_add_cols(self.problemPointer, amount);
}

/**
 @brief Assigns a given symbolic name (1 up to 255 characters) to i-th row (auxiliary variable) of the problem object.
 
 @param name The new name. If the parameter `name` is `nil` or empty string, the routine erases an existing name of i-th row.
 @param i Index of the row to rename.
 */
- (void)setName:(NSString *)name forRow:(int32_t)i {
    glp_set_row_name(self.problemPointer, i, [name cStringUsingEncoding:NSASCIIStringEncoding]);
}

/**
 @brief Assigns a given symbolic `name` (1 up to 255 characters) to j-th column (structural variable) of the speciﬁed problem object.
 
 @param name The new name. If the parameter `name` is `nil` or empty string, the routine erases an existing name of j-th column.
 @param j Index of the column to rename.
 */
- (void)setName:(NSString *)name forColumn:(int32_t)j {
    glp_set_col_name(self.problemPointer, j, [name cStringUsingEncoding:NSASCIIStringEncoding]);
}

/**
 @brief Sets (changes) the type and bounds of j-th column (structural variable) of the speciﬁed problem object.
 
 @param bound The bound to use.
 @param j The index of the column on which the bound will be applied.
 
 @note Being added to the problem object each column is initially ﬁxed at zero.
 */
- (void)setBound:(GLPKBoundType)bound forColumn:(int32_t)j lowerBound:(double)lowerBound upperBound:(double)upperBound {
    // GLPKBoundType is one lower than original GLPK enum
    glp_set_col_bnds(self.problemPointer, j, bound+1, lowerBound, upperBound);
}

/**
 @brief Sets (changes) the type and bounds of i-th row (auxiliary variable) of the speciﬁed problem object.
 
 @param bound The bound to use.
 @param i The index of the row on which the bound will be applied.
 
 @note Being added to the problem object each row is initially free.
 */
- (void)setBound:(GLPKBoundType)bound forRow:(int32_t)i lowerBound:(double)lowerBound upperBound:(double)upperBound {
    // GLPKBoundType is one lower than original GLPK enum
    glp_set_row_bnds(self.problemPointer, i, bound+1, lowerBound, upperBound);
}

/**
 @brief Sets (changes) the objective coefficient at j-th column (structural variable).
 
 @param coefficient The new value of the objective coefficient.
 @param j The index of the column on which the coefficient will be applied.
 If the parameter is 0, the routine sets (changes) the constant term (“shift”) of the objective function.
 */
- (void)setCoefficient:(double)coefficient forColumn:(int32_t)j {
    glp_set_obj_coef(self.problemPointer, j, coefficient);
}

/**
 @brief Add a new row (auxiliary variable) to the current problem.
 
 @param name An optional name to use for the variable.
 @param boundType The bound type to apply to the variable.
 @param lowerBound Value of lower bound. Pass 0 if lower bound is not used.
 @param upperBound Value of upper bound. Pass 0 if upper bound is not used.

 @return The `i` index of the new row.
 */
- (int32_t)addRowWithName:(NSString *)name andBound:(GLPKBoundType)boundType lowerBound:(double)lowerBound upperBound:(double)upperBound {
    int32_t rowIndex = (int32_t)[self addRows:1];
    [self setName:name forRow:rowIndex];
    [self setBound:boundType forRow:rowIndex lowerBound:lowerBound upperBound:upperBound];
    
    return rowIndex;
}

/**
 @brief Add a new column (structural variable) to the current problem.
 
 @param name An optional name to use for the variable.
 @param boundType The bound type to apply to the variable.
 @param lowerBound Value of lower bound. Pass 0 if lower bound is not used.
 @param upperBound Value of upper bound. Pass 0 if upper bound is not used.
 @param coef An optional coefficient to apply to the variable in the objective function.
 
 @return The `j` index of the new column.
 */
- (int32_t)addColumnWithName:(NSString *)name andBound:(GLPKBoundType)boundType lowerBound:(double)lowerBound upperBound:(double)upperBound usingCoefficient:(double)coef {
    int32_t columnIndex = (int32_t)[self addCols:1];
    [self setName:name forColumn:columnIndex];
    [self setBound:boundType forColumn:columnIndex lowerBound:lowerBound upperBound:upperBound];
    [self setCoefficient:coef forColumn:columnIndex];

    return columnIndex;
}

/** @brief Load a matrix by giving its values ordered by row.
 
 To represent the following example matrix:
 
 1 2
 
 3 4
 
 5 6
 
 use the following argument for `matrix`:
 
 NSArray *matrix = @[
 
 @[@1, @2],
 
 @[@3, @4],
 
 @[@5, @6],
 
 ];

 *  @param matrix An array of an array of the values to use.
 **/
- (void)loadConstraintMatrixWithValuesByRow:(NSArray *)matrix {
    int32_t *rows = malloc(sizeof(int32_t)*(matrix.count+1));
    rows[0] = 0;
    NSArray *firstRow = matrix.firstObject;
    int32_t *columns = malloc(sizeof(int32_t)*(firstRow.count+1));
    columns[0] = 0;
    int32_t noValues = (int32_t)matrix.count*(int32_t)firstRow.count;
    double *values = malloc(sizeof(double)*(noValues+1));
    values[0] = 0.0;
    int32_t index = 1;
    int32_t i = 1;
    for (NSArray *row in matrix) {
        int32_t j = 1;
        for (NSNumber *value in row) {
            rows[index] = i;
            columns[index] = j;
            values[index] = value.doubleValue;
            j++;
            index++;
        }
        i++;
    }
    
    // For some reason the XCTestCase fails at this point on iPhone 8 / iOS 11.4, but not on iPad Air 2 / iOS 11.4 (both simulator)
    glp_load_matrix(self.problemPointer, noValues, rows, columns, values);

    free(rows);
    free(columns);
    free(values);
}

/** @brief Retrieves problem data from the specified problem object, calls the solver to solve the problem instance, and stores results of computations back into the problem object.
 **/
- (void)simplex {
    glp_simplex(self.problemPointer, nil);
}

/**
 *  @return The current value of the objective function
 **/
- (double)functionValue {
    return glp_get_obj_val(self.problemPointer);
}

/**
 *  @return The primal value of the structural variable associated with the given column
 **/
- (double)primalValueOfColumn:(int32_t) column {
    return glp_get_col_prim(self.problemPointer, column);
}

/**
 *  @return The primal value of the structural variable associated with the given column
 **/
- (double)primalValueOfColumnWithName:(NSString *)name {
    glp_create_index(self.problemPointer); // has to be called before first call to glp_find_col, can be called any time
    int32_t column = glp_find_col(self.problemPointer, [name cStringUsingEncoding:NSASCIIStringEncoding]);
    return glp_get_col_prim(self.problemPointer, column);
}

/**
 *  @return The current number of rows in the specified problem object.
 **/
- (int32_t)countRows {
    return glp_get_num_rows(self.problemPointer);
}

/**
 *  @return The current number of columns in the specified problem object.
 **/
- (int32_t)countColumns {
    return glp_get_num_rows(self.problemPointer);
}

@end
